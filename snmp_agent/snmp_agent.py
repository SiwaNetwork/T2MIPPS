#!/usr/bin/env python3
"""
SNMP Agent for T2MI PPS Generator
Provides remote monitoring capabilities via SNMP protocol
"""

import time
import serial
import struct
from pysnmp.hlapi import *
from pysnmp.proto import rfc1902
from pysnmp.smi import builder, view, compiler, rfc1902 as smi_rfc1902
from pysnmp.entity import engine, config
from pysnmp.entity.rfc3413 import cmdrsp, context
from pysnmp.carrier.asyncore.dgram import udp
import threading
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class T2MIPPSAgent:
    """SNMP Agent for T2MI PPS Generator monitoring"""
    
    # OID Base: 1.3.6.1.4.1.99999 (example private enterprise number)
    OID_BASE = '1.3.6.1.4.1.99999'
    
    # OID Definitions
    OID_SYSTEM_STATUS = f'{OID_BASE}.1.1.0'      # System status (0=offline, 1=online, 2=error)
    OID_PPS_COUNT = f'{OID_BASE}.1.2.0'          # Total PPS pulses generated
    OID_SYNC_STATUS = f'{OID_BASE}.1.3.0'        # Sync status (0=no sync, 1=synced)
    OID_FREQUENCY_ERROR = f'{OID_BASE}.1.4.0'    # Frequency error in ppb
    OID_PHASE_ERROR = f'{OID_BASE}.1.5.0'        # Phase error in ns
    OID_TEMPERATURE = f'{OID_BASE}.1.6.0'        # Temperature in celsius * 100
    OID_UPTIME = f'{OID_BASE}.1.7.0'             # Uptime in seconds
    OID_LAST_SYNC_TIME = f'{OID_BASE}.1.8.0'     # Last sync timestamp
    OID_T2MI_PACKETS = f'{OID_BASE}.1.9.0'       # T2MI packets received
    OID_ERROR_COUNT = f'{OID_BASE}.1.10.0'       # Error count
    OID_ALLAN_DEVIATION = f'{OID_BASE}.1.11.0'   # Allan deviation * 1e12
    OID_MTIE = f'{OID_BASE}.1.12.0'              # MTIE in ns
    OID_GNSS_STATUS = f'{OID_BASE}.1.13.0'       # GNSS status (0=no fix, 1=2D, 2=3D)
    OID_HOLDOVER_STATUS = f'{OID_BASE}.1.14.0'   # Holdover status (0=normal, 1=holdover)
    OID_DPLL_LOCK = f'{OID_BASE}.1.15.0'         # DPLL lock status (0=unlocked, 1=locked)
    
    def __init__(self, uart_port='/dev/ttyUSB0', uart_baudrate=115200, 
                 snmp_port=161, community='public'):
        self.uart_port = uart_port
        self.uart_baudrate = uart_baudrate
        self.snmp_port = snmp_port
        self.community = community
        
        # Initialize status variables
        self.status = {
            'system_status': 0,
            'pps_count': 0,
            'sync_status': 0,
            'frequency_error': 0,
            'phase_error': 0,
            'temperature': 2500,  # 25.00°C
            'uptime': 0,
            'last_sync_time': 0,
            't2mi_packets': 0,
            'error_count': 0,
            'allan_deviation': 0,
            'mtie': 0,
            'gnss_status': 0,
            'holdover_status': 0,
            'dpll_lock': 0
        }
        
        self.start_time = time.time()
        self.serial_conn = None
        self.snmp_engine = None
        self.running = False
        
    def connect_uart(self):
        """Connect to FPGA via UART"""
        try:
            self.serial_conn = serial.Serial(
                port=self.uart_port,
                baudrate=self.uart_baudrate,
                timeout=1.0
            )
            logger.info(f"Connected to UART on {self.uart_port}")
            return True
        except Exception as e:
            logger.error(f"Failed to connect to UART: {e}")
            return False
    
    def parse_uart_data(self, data):
        """Parse status data from FPGA UART interface"""
        try:
            # Expected format: STATUS:sync,freq_err,phase_err,temp,pps_count,t2mi_packets,errors
            if data.startswith('STATUS:'):
                values = data[7:].strip().split(',')
                if len(values) >= 7:
                    self.status['sync_status'] = int(values[0])
                    self.status['frequency_error'] = int(float(values[1]) * 1e9)  # Convert to ppb
                    self.status['phase_error'] = int(float(values[2]) * 1e9)  # Convert to ns
                    self.status['temperature'] = int(float(values[3]) * 100)
                    self.status['pps_count'] = int(values[4])
                    self.status['t2mi_packets'] = int(values[5])
                    self.status['error_count'] = int(values[6])
                    
                    if len(values) >= 11:
                        self.status['allan_deviation'] = int(float(values[7]) * 1e12)
                        self.status['mtie'] = int(float(values[8]) * 1e9)
                        self.status['gnss_status'] = int(values[9])
                        self.status['dpll_lock'] = int(values[10])
                    
                    self.status['system_status'] = 1 if self.status['sync_status'] else 2
                    if self.status['sync_status']:
                        self.status['last_sync_time'] = int(time.time())
                        
        except Exception as e:
            logger.error(f"Error parsing UART data: {e}")
    
    def uart_monitor_thread(self):
        """Thread to monitor UART data from FPGA"""
        while self.running:
            try:
                if self.serial_conn and self.serial_conn.in_waiting:
                    line = self.serial_conn.readline().decode('utf-8').strip()
                    if line:
                        self.parse_uart_data(line)
                
                # Update uptime
                self.status['uptime'] = int(time.time() - self.start_time)
                
                # Send status request to FPGA
                if self.serial_conn:
                    self.serial_conn.write(b'GET_STATUS\n')
                    
            except Exception as e:
                logger.error(f"UART monitor error: {e}")
                self.status['system_status'] = 2  # Error state
                
            time.sleep(1)
    
    def setup_snmp_agent(self):
        """Setup SNMP agent"""
        # Create SNMP engine
        self.snmp_engine = engine.SnmpEngine()
        
        # Configure transport
        config.addTransport(
            self.snmp_engine,
            udp.domainName,
            udp.UdpTransport().openServerMode(('0.0.0.0', self.snmp_port))
        )
        
        # Configure community
        config.addV1System(self.snmp_engine, 'agent', self.community)
        
        # Configure context
        config.addContext(self.snmp_engine, '')
        
        # Configure access
        config.addVacmUser(self.snmp_engine, 1, 'agent', 'noAuthNoPriv',
                          (1, 3, 6), (1, 3, 6))
        config.addVacmUser(self.snmp_engine, 2, 'agent', 'noAuthNoPriv',
                          (1, 3, 6), (1, 3, 6))
        
        # Create MIB builder
        mibBuilder = self.snmp_engine.msgAndPduDsp.mibInstrumController.mibBuilder
        
        # Register scalar MIB variables
        self._register_scalars(mibBuilder)
        
        # Register command responder
        cmdrsp.GetCommandResponder(self.snmp_engine, context.SnmpContext(self.snmp_engine))
        cmdrsp.NextCommandResponder(self.snmp_engine, context.SnmpContext(self.snmp_engine))
        
        logger.info(f"SNMP agent listening on port {self.snmp_port}")
    
    def _register_scalars(self, mibBuilder):
        """Register scalar MIB variables"""
        # Create custom MIB tree
        (MibScalar, MibScalarInstance) = mibBuilder.importSymbols(
            'SNMPv2-SMI', 'MibScalar', 'MibScalarInstance'
        )
        
        class CustomMibScalarInstance(MibScalarInstance):
            def __init__(self, oid, value_func):
                self.value_func = value_func
                super().__init__(
                    oid, (0,), 
                    MibScalar(oid, rfc1902.Integer32()).setMaxAccess('readonly')
                )
            
            def readTest(self, name, val, idx, acInfo):
                return name, self.value_func()
            
            def readGet(self, name, val, idx, acInfo):
                return name, self.value_func()
        
        # Register all OIDs
        oid_mappings = [
            (self.OID_SYSTEM_STATUS, lambda: self.status['system_status']),
            (self.OID_PPS_COUNT, lambda: self.status['pps_count']),
            (self.OID_SYNC_STATUS, lambda: self.status['sync_status']),
            (self.OID_FREQUENCY_ERROR, lambda: self.status['frequency_error']),
            (self.OID_PHASE_ERROR, lambda: self.status['phase_error']),
            (self.OID_TEMPERATURE, lambda: self.status['temperature']),
            (self.OID_UPTIME, lambda: self.status['uptime']),
            (self.OID_LAST_SYNC_TIME, lambda: self.status['last_sync_time']),
            (self.OID_T2MI_PACKETS, lambda: self.status['t2mi_packets']),
            (self.OID_ERROR_COUNT, lambda: self.status['error_count']),
            (self.OID_ALLAN_DEVIATION, lambda: self.status['allan_deviation']),
            (self.OID_MTIE, lambda: self.status['mtie']),
            (self.OID_GNSS_STATUS, lambda: self.status['gnss_status']),
            (self.OID_HOLDOVER_STATUS, lambda: self.status['holdover_status']),
            (self.OID_DPLL_LOCK, lambda: self.status['dpll_lock'])
        ]
        
        for oid_str, value_func in oid_mappings:
            oid = rfc1902.ObjectIdentifier(oid_str)
            mibBuilder.exportSymbols(
                '__T2MI_PPS_MIB',
                CustomMibScalarInstance(oid, value_func)
            )
    
    def start(self):
        """Start SNMP agent"""
        self.running = True
        
        # Connect to UART
        if not self.connect_uart():
            logger.warning("Running in demo mode without UART connection")
            self._start_demo_mode()
        
        # Setup SNMP agent
        self.setup_snmp_agent()
        
        # Start UART monitor thread
        uart_thread = threading.Thread(target=self.uart_monitor_thread)
        uart_thread.daemon = True
        uart_thread.start()
        
        # Start SNMP dispatcher
        try:
            self.snmp_engine.transportDispatcher.jobStarted(1)
            self.snmp_engine.transportDispatcher.runDispatcher()
        except KeyboardInterrupt:
            self.stop()
    
    def _start_demo_mode(self):
        """Start demo mode with simulated data"""
        def demo_update():
            import random
            while self.running:
                self.status['system_status'] = 1
                self.status['sync_status'] = 1
                self.status['pps_count'] += 1
                self.status['frequency_error'] = random.randint(-50, 50)
                self.status['phase_error'] = random.randint(-100, 100)
                self.status['temperature'] = 2500 + random.randint(-100, 100)
                self.status['t2mi_packets'] += random.randint(0, 10)
                self.status['allan_deviation'] = random.randint(1, 100)
                self.status['mtie'] = random.randint(10, 1000)
                self.status['dpll_lock'] = 1
                time.sleep(1)
        
        demo_thread = threading.Thread(target=demo_update)
        demo_thread.daemon = True
        demo_thread.start()
    
    def stop(self):
        """Stop SNMP agent"""
        self.running = False
        if self.snmp_engine:
            self.snmp_engine.transportDispatcher.jobFinished(1)
        if self.serial_conn:
            self.serial_conn.close()
        logger.info("SNMP agent stopped")

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='T2MI PPS Generator SNMP Agent')
    parser.add_argument('--uart-port', default='/dev/ttyUSB0', help='UART port')
    parser.add_argument('--uart-baudrate', type=int, default=115200, help='UART baudrate')
    parser.add_argument('--snmp-port', type=int, default=161, help='SNMP port')
    parser.add_argument('--community', default='public', help='SNMP community string')
    
    args = parser.parse_args()
    
    agent = T2MIPPSAgent(
        uart_port=args.uart_port,
        uart_baudrate=args.uart_baudrate,
        snmp_port=args.snmp_port,
        community=args.community
    )
    
    try:
        agent.start()
    except Exception as e:
        logger.error(f"Agent failed: {e}")
        agent.stop()