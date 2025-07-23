#!/usr/bin/env python3
"""
Простой SNMP сервер для тестирования T2MI PPS агента
"""

import time
import threading
import logging
from pysnmp.hlapi import *

# Настройка логирования
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class T2MIPPSData:
    """Класс для хранения данных T2MI PPS"""
    
    def __init__(self):
        self.data = {
            '1.3.6.1.4.1.99999.1.1.0': 1,      # Статус системы
            '1.3.6.1.4.1.99999.1.2.0': 0,      # Счетчик PPS
            '1.3.6.1.4.1.99999.1.3.0': 1,      # Статус синхронизации
            '1.3.6.1.4.1.99999.1.4.0': 50,     # Частотная ошибка
            '1.3.6.1.4.1.99999.1.5.0': 25,     # Фазовая ошибка
            '1.3.6.1.4.1.99999.1.6.0': 2500,   # Температура
            '1.3.6.1.4.1.99999.1.7.0': 0,      # Время работы
            '1.3.6.1.4.1.99999.1.8.0': 0,      # Время последней синхронизации
            '1.3.6.1.4.1.99999.1.9.0': 0,      # T2MI пакеты
            '1.3.6.1.4.1.99999.1.10.0': 0,     # Ошибки
            '1.3.6.1.4.1.99999.1.11.0': 1000,  # Девиация Аллана
            '1.3.6.1.4.1.99999.1.12.0': 100,   # MTIE
            '1.3.6.1.4.1.99999.1.13.0': 2,     # GNSS статус
            '1.3.6.1.4.1.99999.1.14.0': 0,     # Статус удержания
            '1.3.6.1.4.1.99999.1.15.0': 1      # DPLL статус
        }
        self.start_time = time.time()
        self.running = False
    
    def update_data(self):
        """Обновление данных"""
        while self.running:
            try:
                # Обновление времени работы
                self.data['1.3.6.1.4.1.99999.1.7.0'] = int(time.time() - self.start_time)
                
                # Имитация увеличения счетчиков
                self.data['1.3.6.1.4.1.99999.1.2.0'] += 1
                self.data['1.3.6.1.4.1.99999.1.9.0'] += 10
                
                # Имитация изменения ошибок
                self.data['1.3.6.1.4.1.99999.1.4.0'] = 50 + int(time.time() % 20) - 10
                self.data['1.3.6.1.4.1.99999.1.5.0'] = 25 + int(time.time() % 10) - 5
                
                # Имитация изменения температуры
                self.data['1.3.6.1.4.1.99999.1.6.0'] = 2500 + int(time.time() % 100)
                
                time.sleep(1)
                
            except Exception as e:
                logger.error(f"Ошибка обновления данных: {e}")
                time.sleep(5)
    
    def get_value(self, oid):
        """Получение значения по OID"""
        return self.data.get(oid, 0)
    
    def print_status(self):
        """Вывод статуса"""
        print("\n" + "="*50)
        print("T2MI PPS SNMP ДАННЫЕ")
        print("="*50)
        print(f"Статус системы: {self.data['1.3.6.1.4.1.99999.1.1.0']}")
        print(f"PPS импульсов: {self.data['1.3.6.1.4.1.99999.1.2.0']:,}")
        print(f"Синхронизация: {self.data['1.3.6.1.4.1.99999.1.3.0']}")
        print(f"Частотная ошибка: {self.data['1.3.6.1.4.1.99999.1.4.0']} ppb")
        print(f"Фазовая ошибка: {self.data['1.3.6.1.4.1.99999.1.5.0']} нс")
        print(f"Температура: {self.data['1.3.6.1.4.1.99999.1.6.0']/100:.2f}°C")
        print(f"Время работы: {self.data['1.3.6.1.4.1.99999.1.7.0']} сек")
        print(f"T2MI пакеты: {self.data['1.3.6.1.4.1.99999.1.9.0']:,}")
        print(f"GNSS статус: {self.data['1.3.6.1.4.1.99999.1.13.0']}")
        print(f"DPLL статус: {self.data['1.3.6.1.4.1.99999.1.15.0']}")
        print("="*50)

def test_snmp_queries():
    """Тестирование SNMP запросов"""
    data = T2MIPPSData()
    
    # Запуск обновления данных
    data.running = True
    update_thread = threading.Thread(target=data.update_data)
    update_thread.daemon = True
    update_thread.start()
    
    logger.info("Тестирование SNMP запросов...")
    logger.info("Используйте следующие команды в другом терминале:")
    logger.info("snmpwalk -v2c -c public localhost 1.3.6.1.4.1.99999")
    logger.info("snmpget -v2c -c public localhost 1.3.6.1.4.1.99999.1.1.0")
    
    try:
        while True:
            # Вывод статуса каждые 15 секунд
            if int(time.time()) % 15 == 0:
                data.print_status()
            
            time.sleep(1)
            
    except KeyboardInterrupt:
        logger.info("Остановка тестирования...")
    finally:
        data.running = False

def main():
    """Главная функция"""
    test_snmp_queries()

if __name__ == '__main__':
    main() 