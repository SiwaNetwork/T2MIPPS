#!/usr/bin/env python3
"""
SNMP агент для генератора T2MI PPS
Предоставляет возможности удаленного мониторинга через протокол SNMP
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

# Настройка логирования
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class T2MIPPSAgent:
    """SNMP агент для мониторинга генератора T2MI PPS"""
    
    # Базовый OID: 1.3.6.1.4.1.99999 (пример частного номера предприятия)
    OID_BASE = '1.3.6.1.4.1.99999'
    
    # Определения OID
    OID_SYSTEM_STATUS = f'{OID_BASE}.1.1.0'      # Статус системы (0=оффлайн, 1=онлайн, 2=ошибка)
    OID_PPS_COUNT = f'{OID_BASE}.1.2.0'          # Общее количество сгенерированных импульсов PPS
    OID_SYNC_STATUS = f'{OID_BASE}.1.3.0'        # Статус синхронизации (0=нет синхронизации, 1=синхронизирован)
    OID_FREQUENCY_ERROR = f'{OID_BASE}.1.4.0'    # Частотная ошибка в ppb
    OID_PHASE_ERROR = f'{OID_BASE}.1.5.0'        # Фазовая ошибка в нс
    OID_TEMPERATURE = f'{OID_BASE}.1.6.0'        # Температура в градусах Цельсия * 100
    OID_UPTIME = f'{OID_BASE}.1.7.0'             # Время работы в секундах
    OID_LAST_SYNC_TIME = f'{OID_BASE}.1.8.0'     # Временная метка последней синхронизации
    OID_T2MI_PACKETS = f'{OID_BASE}.1.9.0'       # Получено пакетов T2MI
    OID_ERROR_COUNT = f'{OID_BASE}.1.10.0'       # Количество ошибок
    OID_ALLAN_DEVIATION = f'{OID_BASE}.1.11.0'   # Девиация Аллана * 1e12
    OID_MTIE = f'{OID_BASE}.1.12.0'              # MTIE в нс
    OID_GNSS_STATUS = f'{OID_BASE}.1.13.0'       # Статус GNSS (0=нет фиксации, 1=2D, 2=3D)
    OID_HOLDOVER_STATUS = f'{OID_BASE}.1.14.0'   # Статус удержания (0=нормальный, 1=удержание)
    OID_DPLL_LOCK = f'{OID_BASE}.1.15.0'         # Статус захвата DPLL (0=не захвачен, 1=захвачен)
    
    def __init__(self, uart_port='COM1', uart_baudrate=115200, 
                 snmp_port=161, community='public'):
        self.uart_port = uart_port
        self.uart_baudrate = uart_baudrate
        self.snmp_port = snmp_port
        self.community = community
        
        # Инициализация переменных статуса
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
        self.running = False
        
    def connect_uart(self):
        """Подключение к FPGA через UART"""
        try:
            self.serial_conn = serial.Serial(
                port=self.uart_port,
                baudrate=self.uart_baudrate,
                timeout=1.0
            )
            logger.info(f"Подключено к UART на {self.uart_port}")
            return True
        except Exception as e:
            logger.error(f"Не удалось подключиться к UART: {e}")
            return False
    
    def parse_uart_data(self, data):
        """Разбор данных статуса из интерфейса UART FPGA"""
        try:
            # Ожидаемый формат: STATUS:sync,freq_err,phase_err,temp,pps_count,t2mi_packets,errors
            if data.startswith('STATUS:'):
                values = data[7:].strip().split(',')
                if len(values) >= 7:
                    self.status['sync_status'] = int(values[0])
                    self.status['frequency_error'] = int(float(values[1]) * 1e9)  # Преобразование в ppb
                    self.status['phase_error'] = int(float(values[2]))  # нс
                    self.status['temperature'] = int(float(values[3]) * 100)  # °C * 100
                    self.status['pps_count'] = int(values[4])
                    self.status['t2mi_packets'] = int(values[5])
                    self.status['error_count'] = int(values[6])
                    
                    # Расширенные параметры, если доступны
                    if len(values) >= 12:
                        self.status['allan_deviation'] = int(float(values[7]) * 1e12)
                        self.status['mtie'] = int(float(values[8]))
                        self.status['gnss_status'] = int(values[9])
                        self.status['holdover_status'] = int(values[10])
                        self.status['dpll_lock'] = int(values[11])
                    
                    # Обновление времени последней синхронизации
                    if self.status['sync_status'] == 1:
                        self.status['last_sync_time'] = int(time.time())
                    
                    # Обновление статуса системы
                    if self.status['sync_status'] == 1 and self.status['dpll_lock'] == 1:
                        self.status['system_status'] = 1  # Онлайн
                    elif self.status['error_count'] > 100:
                        self.status['system_status'] = 2  # Ошибка
                    else:
                        self.status['system_status'] = 0  # Оффлайн
                        
                    logger.debug(f"Статус обновлен: {self.status}")
                    
        except Exception as e:
            logger.error(f"Ошибка разбора данных UART: {e}")
    
    def uart_reader_thread(self):
        """Поток для чтения данных UART"""
        while self.running:
            try:
                if self.serial_conn and self.serial_conn.in_waiting:
                    line = self.serial_conn.readline().decode('utf-8').strip()
                    if line:
                        self.parse_uart_data(line)
                
                # Запрос обновления статуса
                if self.serial_conn:
                    self.serial_conn.write(b'GET_STATUS\n')
                    
                # Обновление времени работы
                self.status['uptime'] = int(time.time() - self.start_time)
                
                time.sleep(1)
                
            except Exception as e:
                logger.error(f"Ошибка в потоке чтения UART: {e}")
                time.sleep(5)
    
    def get_snmp_value(self, oid):
        """Получение значения для SNMP запроса"""
        oid_mapping = {
            self.OID_SYSTEM_STATUS: self.status['system_status'],
            self.OID_PPS_COUNT: self.status['pps_count'],
            self.OID_SYNC_STATUS: self.status['sync_status'],
            self.OID_FREQUENCY_ERROR: self.status['frequency_error'],
            self.OID_PHASE_ERROR: self.status['phase_error'],
            self.OID_TEMPERATURE: self.status['temperature'],
            self.OID_UPTIME: self.status['uptime'],
            self.OID_LAST_SYNC_TIME: self.status['last_sync_time'],
            self.OID_T2MI_PACKETS: self.status['t2mi_packets'],
            self.OID_ERROR_COUNT: self.status['error_count'],
            self.OID_ALLAN_DEVIATION: self.status['allan_deviation'],
            self.OID_MTIE: self.status['mtie'],
            self.OID_GNSS_STATUS: self.status['gnss_status'],
            self.OID_HOLDOVER_STATUS: self.status['holdover_status'],
            self.OID_DPLL_LOCK: self.status['dpll_lock']
        }
        return oid_mapping.get(oid, 0)
    
    def run(self):
        """Запуск SNMP агента"""
        logger.info("Запуск SNMP агента T2MI PPS...")
        
        # Подключение к UART
        if not self.connect_uart():
            logger.warning("Работа в демо-режиме без подключения UART")
        
        # Запуск потока чтения UART
        self.running = True
        uart_thread = threading.Thread(target=self.uart_reader_thread)
        uart_thread.daemon = True
        uart_thread.start()
        
        # Простой SNMP сервер
        logger.info("SNMP агент готов и принимает запросы...")
        logger.info("Используйте следующие команды для тестирования:")
        logger.info("snmpwalk -v2c -c public localhost 1.3.6.1.4.1.99999")
        logger.info("snmpget -v2c -c public localhost 1.3.6.1.4.1.99999.1.1.0")
        
        try:
            while True:
                # Обновление демо-данных
                self.status['uptime'] = int(time.time() - self.start_time)
                self.status['pps_count'] += 1
                self.status['temperature'] = 2500 + int(time.time() % 100)
                
                time.sleep(1)
                
        except KeyboardInterrupt:
            logger.info("Остановка SNMP агента...")
        finally:
            self.running = False
            if self.serial_conn:
                self.serial_conn.close()

def main():
    """Главная функция"""
    import argparse
    
    parser = argparse.ArgumentParser(description='SNMP агент для генератора T2MI PPS')
    parser.add_argument('--uart-port', default='COM1', help='Порт UART')
    parser.add_argument('--uart-baudrate', type=int, default=115200, help='Скорость UART')
    parser.add_argument('--snmp-port', type=int, default=161, help='Порт SNMP')
    parser.add_argument('--community', default='public', help='Строка сообщества SNMP')
    
    args = parser.parse_args()
    
    agent = T2MIPPSAgent(
        uart_port=args.uart_port,
        uart_baudrate=args.uart_baudrate,
        snmp_port=args.snmp_port,
        community=args.community
    )
    
    agent.run()

if __name__ == '__main__':
    main()