#!/usr/bin/env python3
"""
Веб-интерфейс для генератора T2MI PPS
Предоставляет интерфейс конфигурации и диагностики
"""

from flask import Flask, render_template, jsonify, request, send_from_directory, session, redirect, url_for
from flask_socketio import SocketIO, emit
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash
import serial
import threading
import time
import json
import os
from datetime import datetime, timedelta
import logging
from collections import deque
import numpy as np
import secrets
from satellite_delay_calculator import SatelliteDelayCalculator

# Настройка логирования
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', secrets.token_hex(32))
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(hours=24)

# Инициализация Flask-Login
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

socketio = SocketIO(app, cors_allowed_origins="*")

# Простой класс пользователя для аутентификации
class User(UserMixin):
    def __init__(self, id, username, password_hash):
        self.id = id
        self.username = username
        self.password_hash = password_hash

# Хранилище пользователей в памяти (в продакшене используйте базу данных)
users = {
    'admin': User('1', 'admin', generate_password_hash('admin123')),
    'operator': User('2', 'operator', generate_password_hash('operator123'))
}

@login_manager.user_loader
def load_user(user_id):
    for user in users.values():
        if user.id == user_id:
            return user
    return None

# Глобальные переменные
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
    'satellite_delay_active': False,
    'satellite_delay_value': 0.0,
    'timestamp': datetime.now().isoformat()
}

# Конфигурация
config = {
    'uart_port': '/dev/ttyUSB0',
    'uart_baudrate': 115200,
    'dpll_bandwidth': 0.1,
    'holdover_threshold': 100,
    'temperature_compensation': True,
    'gnss_enabled': True,
    'allan_deviation_window': 100,
    'mtie_window': 1000,
    'satellite_delay_compensation': 0.0,  # Компенсация задержки сигнала от геостационарного спутника (мс)
    'satellite_delay_enabled': False      # Включение/выключение компенсации
}

# Хранилище исторических данных (для графиков)
history_length = 1000
history = {
    'timestamps': deque(maxlen=history_length),
    'frequency_error': deque(maxlen=history_length),
    'phase_error': deque(maxlen=history_length),
    'temperature': deque(maxlen=history_length),
    'allan_deviation': deque(maxlen=history_length),
    'mtie': deque(maxlen=history_length),
    'pps_count': deque(maxlen=history_length)
}

def uart_reader():
    """Читает данные из UART и обновляет статус"""
    global uart_connection, status_data
    
    while True:
        try:
            if uart_connection and uart_connection.is_open:
                line = uart_connection.readline().decode('utf-8').strip()
                if line:
                    try:
                        data = json.loads(line)
                        status_data.update(data)
                        status_data['timestamp'] = datetime.now().isoformat()
                        status_data['system_status'] = 'online'
                        
                        # Применение компенсации задержки спутника
                        if config['satellite_delay_enabled']:
                            status_data['satellite_delay_active'] = True
                            status_data['satellite_delay_value'] = config['satellite_delay_compensation']
                        else:
                            status_data['satellite_delay_active'] = False
                            status_data['satellite_delay_value'] = 0.0
                        
                        # Обновление истории
                        now = datetime.now()
                        history['timestamps'].append(now.isoformat())
                        history['frequency_error'].append(status_data.get('frequency_error', 0))
                        history['phase_error'].append(status_data.get('phase_error', 0))
                        history['temperature'].append(status_data.get('temperature', 25))
                        history['allan_deviation'].append(status_data.get('allan_deviation', 0))
                        history['mtie'].append(status_data.get('mtie', 0))
                        history['pps_count'].append(status_data.get('pps_count', 0))
                        
                        socketio.emit('status_update', status_data)
                    except json.JSONDecodeError:
                        logger.error(f"Ошибка декодирования JSON: {line}")
            else:
                status_data['system_status'] = 'offline'
                time.sleep(1)
        except Exception as e:
            logger.error(f"Ошибка чтения UART: {e}")
            status_data['system_status'] = 'error'
            time.sleep(1)

def uart_writer(command):
    """Отправляет команду в UART"""
    global uart_connection
    
    try:
        if uart_connection and uart_connection.is_open:
            uart_connection.write(f"{command}\n".encode('utf-8'))
            return True
    except Exception as e:
        logger.error(f"Ошибка записи в UART: {e}")
    return False

def connect_uart():
    """Подключается к UART"""
    global uart_connection
    
    try:
        uart_connection = serial.Serial(
            port=config['uart_port'],
            baudrate=config['uart_baudrate'],
            timeout=1
        )
        logger.info(f"Подключено к UART: {config['uart_port']}")
        
        # Отправка конфигурации в FPGA
        send_config_to_fpga()
        
        return True
    except Exception as e:
        logger.error(f"Ошибка подключения к UART: {e}")
        return False

def send_config_to_fpga():
    """Отправляет текущую конфигурацию в FPGA"""
    commands = [
        f"set_bandwidth {config['dpll_bandwidth']}",
        f"set_holdover_threshold {config['holdover_threshold']}",
        f"set_temp_comp {'on' if config['temperature_compensation'] else 'off'}",
        f"set_gnss {'on' if config['gnss_enabled'] else 'off'}",
        f"set_allan_window {config['allan_deviation_window']}",
        f"set_mtie_window {config['mtie_window']}"
    ]
    
    # Добавление команды компенсации задержки спутника
    if config['satellite_delay_enabled']:
        delay_us = int(config['satellite_delay_compensation'] * 1000)  # Перевод мс в мкс
        commands.append(f"set_sat_delay {delay_us}")
        commands.append("enable_sat_delay")
    else:
        commands.append("disable_sat_delay")
    
    for cmd in commands:
        uart_writer(cmd)
        time.sleep(0.1)

# Эмуляция реального времени для тестирования
def status_updater():
    """Обновляет статус в реальном времени (для тестирования без FPGA)"""
    global status_data
    
    start_time = time.time()
    
    while True:
        try:
            # Эмуляция реального времени
            if not uart_connection or not uart_connection.is_open:
                current_time = time.time()
                elapsed = current_time - start_time
                
                status_data['uptime'] = int(elapsed)
                status_data['pps_count'] = int(elapsed)
                status_data['frequency_error'] = np.sin(elapsed * 0.1) * 10
                status_data['phase_error'] = np.cos(elapsed * 0.05) * 100
                status_data['temperature'] = 25 + np.sin(elapsed * 0.01) * 5
                status_data['allan_deviation'] = abs(np.sin(elapsed * 0.02)) * 1e-11
                status_data['mtie'] = abs(np.sin(elapsed * 0.03)) * 100
                status_data['t2mi_packets'] = int(elapsed * 10)
                status_data['sync_status'] = True
                status_data['dpll_lock'] = True
                status_data['timestamp'] = datetime.now().isoformat()
                
                # Обновление истории
                now = datetime.now()
                history['timestamps'].append(now.isoformat())
                history['frequency_error'].append(status_data['frequency_error'])
                history['phase_error'].append(status_data['phase_error'])
                history['temperature'].append(status_data['temperature'])
                history['allan_deviation'].append(status_data['allan_deviation'])
                history['mtie'].append(status_data['mtie'])
                history['pps_count'].append(status_data['pps_count'])
                
                # Отправка обновления подключенным клиентам
                socketio.emit('status_update', status_data)
            
            time.sleep(1)  # Обновление каждую секунду
        except Exception as e:
            logger.error(f"Ошибка в обновлении статуса: {e}")
            time.sleep(1)

# Запрос обновления статуса
@socketio.on('request_status')
def handle_status_request():
    emit('status_update', status_data)

# Обновление времени работы
@socketio.on('connect')
def handle_connect():
    logger.info(f"Клиент подключен: {request.sid}")
    emit('status_update', status_data)

@socketio.on('disconnect')
def handle_disconnect():
    logger.info(f"Клиент отключен: {request.sid}")

@app.route('/')
def index():
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        user = users.get(username)
        if user and check_password_hash(user.password_hash, password):
            login_user(user)
            return redirect(url_for('dashboard'))
        else:
            return render_template('login.html', error='Неверное имя пользователя или пароль')
    
    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))

@app.route('/dashboard')
@login_required
def dashboard():
    return render_template('dashboard.html', username=current_user.username)

@app.route('/api/status')
@login_required
def get_status():
    return jsonify(status_data)

@app.route('/api/config', methods=['GET', 'POST'])
@login_required
def handle_config():
    if request.method == 'POST':
        new_config = request.json
        config.update(new_config)
        
        # Отправка конфигурации в FPGA
        send_config_to_fpga()
        
        return jsonify({'status': 'success', 'config': config})
    else:
        return jsonify(config)

@app.route('/api/history')
@login_required
def get_history():
    # Преобразование deque в списки и подготовка данных для графиков
    return jsonify({
        'timestamps': list(history['timestamps']),
        'frequency_error': list(history['frequency_error']),
        'phase_error': list(history['phase_error']),
        'temperature': list(history['temperature']),
        'allan_deviation': list(history['allan_deviation']),
        'mtie': list(history['mtie']),
        'pps_count': list(history['pps_count'])
    })

@app.route('/api/command', methods=['POST'])
@login_required
def send_command():
    command = request.json.get('command')
    if command:
        success = uart_writer(command)
        return jsonify({'status': 'success' if success else 'error'})
    return jsonify({'status': 'error', 'message': 'Команда не указана'})

@app.route('/api/connect', methods=['POST'])
@login_required
def connect():
    if connect_uart():
        return jsonify({'status': 'success'})
    return jsonify({'status': 'error'})

@app.route('/api/disconnect', methods=['POST'])
@login_required
def disconnect():
    global uart_connection
    if uart_connection:
        uart_connection.close()
        uart_connection = None
    return jsonify({'status': 'success'})

# События WebSocket
@socketio.on('update_config')
@login_required
def handle_config_update(data):
    config.update(data)
    send_config_to_fpga()
    emit('config_updated', config, broadcast=True)

@socketio.on('send_command')
@login_required
def handle_command(data):
    command = data.get('command')
    if command:
        uart_writer(command)
        emit('command_sent', {'command': command}, broadcast=True)

# Статические файлы
@app.route('/static/<path:path>')
def send_static(path):
    return send_from_directory('static', path)

@app.route('/api/satellite_delay', methods=['POST'])
@login_required
def calculate_satellite_delay():
    """
    Рассчитывает задержку распространения сигнала через спутник
    """
    try:
        data = request.json
        
        # Извлечение параметров
        tx_lat = float(data.get('tx_latitude', 0))
        tx_lon = float(data.get('tx_longitude', 0))
        tx_alt = float(data.get('tx_altitude', 0))
        rx_lat = float(data.get('rx_latitude', 0))
        rx_lon = float(data.get('rx_longitude', 0))
        rx_alt = float(data.get('rx_altitude', 0))
        sat_lon = float(data.get('satellite_longitude', 0))
        
        # Создание экземпляра калькулятора
        calc = SatelliteDelayCalculator()
        
        # Расчет задержки
        result = calc.calculate_delay(
            tx_lat, tx_lon, tx_alt,
            rx_lat, rx_lon, rx_alt,
            sat_lon
        )
        
        # Добавление типичных значений для справки
        result['typical_values'] = calc.get_typical_delays()
        
        # Добавление команды UART
        delay_us = int(result['total_delay'] * 1000)  # мс в мкс
        result['uart_command'] = f"set_sat_delay {delay_us}"
        
        return jsonify(result)
        
    except Exception as e:
        logger.error(f"Ошибка расчета задержки спутника: {e}")
        return jsonify({'error': str(e)}), 400

@app.route('/api/satellite_delay/apply', methods=['POST'])
@login_required
def apply_satellite_delay():
    """
    Применяет рассчитанную задержку спутника
    """
    try:
        data = request.json
        delay_ms = float(data.get('delay', 0))
        enable = bool(data.get('enable', True))
        
        # Обновление конфигурации
        config['satellite_delay_compensation'] = delay_ms
        config['satellite_delay_enabled'] = enable
        
        # Отправка команд в FPGA
        if enable:
            delay_us = int(delay_ms * 1000)
            uart_writer(f"set_sat_delay {delay_us}")
            uart_writer("enable_sat_delay")
        else:
            uart_writer("disable_sat_delay")
        
        # Ожидание ответа
        time.sleep(0.5)
        
        return jsonify({
            'status': 'success',
            'delay': delay_ms,
            'enabled': enable
        })
        
    except Exception as e:
        logger.error(f"Ошибка применения задержки спутника: {e}")
        return jsonify({'error': str(e)}), 400

@app.route('/api/satellite_delay/status', methods=['GET'])
@login_required
def get_satellite_delay_status():
    """
    Возвращает текущий статус компенсации задержки спутника
    """
    return jsonify({
        'enabled': config.get('satellite_delay_enabled', False),
        'delay': config.get('satellite_delay_compensation', 0.0),
        'active': status_data.get('satellite_delay_active', False),
        'current_value': status_data.get('satellite_delay_value', 0.0)
    })

if __name__ == '__main__':
    # Запуск потока чтения UART
    uart_thread = threading.Thread(target=uart_reader, daemon=True)
    uart_thread.start()
    
    # Запуск потока обновления статуса
    status_thread = threading.Thread(target=status_updater, daemon=True)
    status_thread.start()
    
    # Попытка подключения к UART при запуске
    connect_uart()
    
    # Запуск веб-сервера
    socketio.run(app, host='0.0.0.0', port=5000, debug=True)