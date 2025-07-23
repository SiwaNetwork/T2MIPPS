#!/usr/bin/env python3
"""
Упрощенный SNMP агент для генератора T2MI PPS
Демо-версия для тестирования
"""

import time
import threading
import logging
from datetime import datetime

# Настройка логирования
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class SimpleT2MIPPSAgent:
    """Упрощенный SNMP агент для мониторинга генератора T2MI PPS"""
    
    def __init__(self):
        # Инициализация переменных статуса
        self.status = {
            'system_status': 1,        # 1 = онлайн
            'pps_count': 0,
            'sync_status': 1,          # 1 = синхронизирован
            'frequency_error': 50,      # 50 ppb
            'phase_error': 25,          # 25 нс
            'temperature': 2500,        # 25.00°C
            'uptime': 0,
            'last_sync_time': 0,
            't2mi_packets': 0,
            'error_count': 0,
            'allan_deviation': 1000,   # 1e-12
            'mtie': 100,               # 100 нс
            'gnss_status': 2,          # 2 = 3D фиксация
            'holdover_status': 0,      # 0 = нормальный режим
            'dpll_lock': 1             # 1 = захвачен
        }
        
        self.start_time = time.time()
        self.running = False
        
    def update_demo_data(self):
        """Обновление демо-данных"""
        while self.running:
            try:
                # Обновление времени работы
                self.status['uptime'] = int(time.time() - self.start_time)
                
                # Имитация увеличения счетчиков
                self.status['pps_count'] += 1
                self.status['t2mi_packets'] += 10
                
                # Имитация изменения температуры
                self.status['temperature'] = 2500 + int(time.time() % 100)
                
                # Имитация изменения ошибок
                self.status['frequency_error'] = 50 + int(time.time() % 20) - 10
                self.status['phase_error'] = 25 + int(time.time() % 10) - 5
                
                # Обновление времени последней синхронизации
                if int(time.time()) % 60 == 0:  # Каждую минуту
                    self.status['last_sync_time'] = int(time.time())
                
                time.sleep(1)
                
            except Exception as e:
                logger.error(f"Ошибка обновления данных: {e}")
                time.sleep(5)
    
    def print_status(self):
        """Вывод текущего статуса"""
        print("\n" + "="*50)
        print("СТАТУС T2MI PPS ГЕНЕРАТОРА")
        print("="*50)
        print(f"Статус системы: {'Онлайн' if self.status['system_status'] == 1 else 'Оффлайн' if self.status['system_status'] == 0 else 'Ошибка'}")
        print(f"Синхронизация: {'Синхронизирован' if self.status['sync_status'] == 1 else 'Не синхронизирован'}")
        print(f"PPS импульсов: {self.status['pps_count']:,}")
        print(f"T2MI пакетов: {self.status['t2mi_packets']:,}")
        print(f"Частотная ошибка: {self.status['frequency_error']} ppb")
        print(f"Фазовая ошибка: {self.status['phase_error']} нс")
        print(f"Температура: {self.status['temperature']/100:.2f}°C")
        print(f"Время работы: {self.status['uptime']} сек")
        print(f"GNSS статус: {'3D' if self.status['gnss_status'] == 2 else '2D' if self.status['gnss_status'] == 1 else 'Нет фиксации'}")
        print(f"DPLL захват: {'Захвачен' if self.status['dpll_lock'] == 1 else 'Не захвачен'}")
        print(f"Девиация Аллана: {self.status['allan_deviation']/1e12:.2e}")
        print(f"MTIE: {self.status['mtie']} нс")
        print(f"Ошибки: {self.status['error_count']}")
        print("="*50)
    
    def run(self):
        """Запуск агента"""
        logger.info("Запуск упрощенного SNMP агента T2MI PPS...")
        
        # Запуск потока обновления данных
        self.running = True
        update_thread = threading.Thread(target=self.update_demo_data)
        update_thread.daemon = True
        update_thread.start()
        
        logger.info("Агент запущен в демо-режиме")
        logger.info("Доступные OID для тестирования:")
        logger.info("1.3.6.1.4.1.99999.1.1.0 - Статус системы")
        logger.info("1.3.6.1.4.1.99999.1.2.0 - Счетчик PPS")
        logger.info("1.3.6.1.4.1.99999.1.3.0 - Статус синхронизации")
        logger.info("1.3.6.1.4.1.99999.1.4.0 - Частотная ошибка")
        logger.info("1.3.6.1.4.1.99999.1.5.0 - Фазовая ошибка")
        logger.info("1.3.6.1.4.1.99999.1.6.0 - Температура")
        logger.info("1.3.6.1.4.1.99999.1.7.0 - Время работы")
        logger.info("1.3.6.1.4.1.99999.1.9.0 - T2MI пакеты")
        logger.info("1.3.6.1.4.1.99999.1.10.0 - Количество ошибок")
        logger.info("1.3.6.1.4.1.99999.1.11.0 - Девиация Аллана")
        logger.info("1.3.6.1.4.1.99999.1.12.0 - MTIE")
        logger.info("1.3.6.1.4.1.99999.1.13.0 - GNSS статус")
        logger.info("1.3.6.1.4.1.99999.1.15.0 - DPLL статус")
        
        try:
            while True:
                # Вывод статуса каждые 10 секунд
                if int(time.time()) % 10 == 0:
                    self.print_status()
                
                time.sleep(1)
                
        except KeyboardInterrupt:
            logger.info("Остановка агента...")
        finally:
            self.running = False

def main():
    """Главная функция"""
    agent = SimpleT2MIPPSAgent()
    agent.run()

if __name__ == '__main__':
    main() 