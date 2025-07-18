#!/usr/bin/env python3
"""
Web Interface for T2MI PPS Generator
Provides configuration and diagnostics interface
"""

from flask import Flask, render_template, jsonify, request, send_from_directory
from flask_socketio import SocketIO, emit
import serial
import threading
import time
import json
import os
from datetime import datetime
import logging
from collections import deque
import numpy as np

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key-change-in-production'
socketio = SocketIO(app, cors_allowed_origins="*")

# Global variables
uart_connection = None
status_data = {
    'system_status': 'offline',
    'sync_status': False,
    'pps_count': 0,
    'frequency_error': 0.0,
    'phase_error': 0.0,
    'temperature': 25.0,
    'uptime': 0,
    't2mi_packets': 0,
    'error_count': 0,
    'allan_deviation': 0.0,
    'mtie': 0.0,
    'gnss_status': 'no_fix',
    'holdover_status': False,
    'dpll_lock': False,
    'timestamp': datetime.now().isoformat()
}

# Configuration
config = {
    'uart_port': '/dev/ttyUSB0',
    'uart_baudrate': 115200,
    'dpll_bandwidth': 0.1,
    'holdover_threshold': 100,
    'temperature_compensation': True,
    'gnss_enabled': True,
    'allan_deviation_window': 100,
    'mtie_window': 1000
}

# Historical data storage (for charts)
history_length = 1000
history = {
    'timestamps': deque(maxlen=history_length),
    'frequency_error': deque(maxlen=history_length),
    'phase_error': deque(maxlen=history_length),
    'temperature': deque(maxlen=history_length),
    'allan_deviation': deque(maxlen=history_length),
    'mtie': deque(maxlen=history_length)
}

def connect_uart():
    """Connect to FPGA via UART"""
    global uart_connection
    try:
        uart_connection = serial.Serial(
            port=config['uart_port'],
            baudrate=config['uart_baudrate'],
            timeout=1.0
        )
        logger.info(f"Connected to UART on {config['uart_port']}")
        return True
    except Exception as e:
        logger.error(f"Failed to connect to UART: {e}")
        return False

def parse_uart_data(data):
    """Parse status data from FPGA"""
    global status_data
    try:
        if data.startswith('STATUS:'):
            values = data[7:].strip().split(',')
            if len(values) >= 7:
                status_data['sync_status'] = bool(int(values[0]))
                status_data['frequency_error'] = float(values[1])
                status_data['phase_error'] = float(values[2])
                status_data['temperature'] = float(values[3])
                status_data['pps_count'] = int(values[4])
                status_data['t2mi_packets'] = int(values[5])
                status_data['error_count'] = int(values[6])
                
                if len(values) >= 11:
                    status_data['allan_deviation'] = float(values[7])
                    status_data['mtie'] = float(values[8])
                    status_data['gnss_status'] = ['no_fix', '2d_fix', '3d_fix'][int(values[9])]
                    status_data['dpll_lock'] = bool(int(values[10]))
                
                status_data['system_status'] = 'online' if status_data['sync_status'] else 'warning'
                status_data['timestamp'] = datetime.now().isoformat()
                
                # Update history
                history['timestamps'].append(time.time())
                history['frequency_error'].append(status_data['frequency_error'])
                history['phase_error'].append(status_data['phase_error'])
                history['temperature'].append(status_data['temperature'])
                history['allan_deviation'].append(status_data['allan_deviation'])
                history['mtie'].append(status_data['mtie'])
                
    except Exception as e:
        logger.error(f"Error parsing UART data: {e}")
        status_data['system_status'] = 'error'

def send_uart_command(command):
    """Send command to FPGA via UART"""
    if uart_connection:
        try:
            uart_connection.write(f"{command}\n".encode())
            return True
        except Exception as e:
            logger.error(f"Error sending UART command: {e}")
            return False
    return False

def uart_monitor_thread():
    """Background thread to monitor UART data"""
    while True:
        try:
            if uart_connection and uart_connection.in_waiting:
                line = uart_connection.readline().decode('utf-8').strip()
                if line:
                    parse_uart_data(line)
                    # Emit real-time update to connected clients
                    socketio.emit('status_update', status_data)
            
            # Request status update
            if uart_connection:
                send_uart_command('GET_STATUS')
                
            # Update uptime
            if 'start_time' in globals():
                status_data['uptime'] = int(time.time() - start_time)
                
        except Exception as e:
            logger.error(f"UART monitor error: {e}")
            status_data['system_status'] = 'error'
            
        time.sleep(1)

def demo_mode_thread():
    """Demo mode with simulated data"""
    import random
    import math
    
    phase = 0
    while True:
        phase += 0.1
        
        status_data['system_status'] = 'online'
        status_data['sync_status'] = True
        status_data['pps_count'] += 1
        status_data['frequency_error'] = 5 * math.sin(phase) + random.uniform(-1, 1)
        status_data['phase_error'] = 10 * math.cos(phase) + random.uniform(-2, 2)
        status_data['temperature'] = 25.0 + 2 * math.sin(phase * 0.1) + random.uniform(-0.5, 0.5)
        status_data['t2mi_packets'] += random.randint(5, 15)
        status_data['allan_deviation'] = abs(random.gauss(5e-12, 1e-12))
        status_data['mtie'] = abs(random.gauss(50, 10))
        status_data['gnss_status'] = '3d_fix'
        status_data['dpll_lock'] = True
        status_data['timestamp'] = datetime.now().isoformat()
        
        # Update history
        history['timestamps'].append(time.time())
        history['frequency_error'].append(status_data['frequency_error'])
        history['phase_error'].append(status_data['phase_error'])
        history['temperature'].append(status_data['temperature'])
        history['allan_deviation'].append(status_data['allan_deviation'])
        history['mtie'].append(status_data['mtie'])
        
        # Emit update
        socketio.emit('status_update', status_data)
        
        time.sleep(1)

# Routes
@app.route('/')
def index():
    """Main dashboard page"""
    return render_template('index.html')

@app.route('/api/status')
def get_status():
    """Get current status"""
    return jsonify(status_data)

@app.route('/api/config', methods=['GET', 'POST'])
def handle_config():
    """Get or update configuration"""
    if request.method == 'POST':
        new_config = request.json
        config.update(new_config)
        
        # Send configuration to FPGA
        if 'dpll_bandwidth' in new_config:
            send_uart_command(f"SET_DPLL_BW:{new_config['dpll_bandwidth']}")
        if 'holdover_threshold' in new_config:
            send_uart_command(f"SET_HOLDOVER_TH:{new_config['holdover_threshold']}")
        if 'temperature_compensation' in new_config:
            send_uart_command(f"SET_TEMP_COMP:{int(new_config['temperature_compensation'])}")
        if 'gnss_enabled' in new_config:
            send_uart_command(f"SET_GNSS:{int(new_config['gnss_enabled'])}")
            
        return jsonify({'status': 'success', 'config': config})
    
    return jsonify(config)

@app.route('/api/history')
def get_history():
    """Get historical data for charts"""
    # Convert deques to lists and prepare chart data
    chart_data = {
        'timestamps': list(history['timestamps']),
        'frequency_error': list(history['frequency_error']),
        'phase_error': list(history['phase_error']),
        'temperature': list(history['temperature']),
        'allan_deviation': list(history['allan_deviation']),
        'mtie': list(history['mtie'])
    }
    return jsonify(chart_data)

@app.route('/api/command', methods=['POST'])
def send_command():
    """Send custom command to FPGA"""
    command = request.json.get('command', '')
    if command:
        success = send_uart_command(command)
        return jsonify({'status': 'success' if success else 'error'})
    return jsonify({'status': 'error', 'message': 'No command provided'})

@app.route('/api/reset', methods=['POST'])
def reset_system():
    """Reset the system"""
    send_uart_command('RESET')
    return jsonify({'status': 'success'})

@app.route('/api/calibrate', methods=['POST'])
def calibrate_system():
    """Start calibration procedure"""
    send_uart_command('CALIBRATE')
    return jsonify({'status': 'success', 'message': 'Calibration started'})

# WebSocket events
@socketio.on('connect')
def handle_connect():
    """Handle client connection"""
    logger.info('Client connected')
    emit('status_update', status_data)

@socketio.on('disconnect')
def handle_disconnect():
    """Handle client disconnection"""
    logger.info('Client disconnected')

@socketio.on('request_update')
def handle_update_request():
    """Handle manual update request"""
    emit('status_update', status_data)

# Static files
@app.route('/static/<path:path>')
def send_static(path):
    """Serve static files"""
    return send_from_directory('static', path)

if __name__ == '__main__':
    # Initialize
    start_time = time.time()
    
    # Try to connect to UART
    if not connect_uart():
        logger.warning("Running in demo mode")
        # Start demo mode thread
        demo_thread = threading.Thread(target=demo_mode_thread)
        demo_thread.daemon = True
        demo_thread.start()
    else:
        # Start UART monitor thread
        monitor_thread = threading.Thread(target=uart_monitor_thread)
        monitor_thread.daemon = True
        monitor_thread.start()
    
    # Run Flask app with SocketIO
    socketio.run(app, host='0.0.0.0', port=5000, debug=False)