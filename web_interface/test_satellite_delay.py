#!/usr/bin/env python3
"""
Тестовый скрипт для API задержки спутника
Тестирует конечные точки расчета и применения задержки спутника
"""

import requests
import json
import time

# Конфигурация
BASE_URL = "http://localhost:5000"
USERNAME = "admin"
PASSWORD = "admin123"

class TestSatelliteDelayAPI:
    def __init__(self):
        self.session = requests.Session()
        self.logged_in = False
        
    def login(self):
        """Вход в систему"""
        response = self.session.post(f"{BASE_URL}/login", data={
            'username': USERNAME,
            'password': PASSWORD
        })
        if response.status_code == 200:
            self.logged_in = True
            print("✓ Вход выполнен успешно")
        else:
            print("✗ Ошибка входа")
            
    def test_calculate_delay(self):
        """Тест расчета задержки"""
        print("\n--- Тест расчета задержки ---")
        
        data = {
            'tx_latitude': 55.7558,
            'tx_longitude': 37.6173,
            'tx_altitude': 200,
            'rx_latitude': 59.9311,
            'rx_longitude': 30.3609,
            'rx_altitude': 100,
            'satellite_longitude': 36.0
        }
        
        response = self.session.post(f"{BASE_URL}/api/satellite_delay", json=data)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✓ Расчет выполнен успешно")
            print(f"  Полная задержка: {result['total_delay']:.3f} мс")
            print(f"  Задержка в свободном пространстве: {result['free_space_delay']:.3f} мс")
            print(f"  Тропосферная задержка: {result['tropospheric_delay']:.3f} мс")
            print(f"  Ионосферная задержка: {result['ionospheric_delay']:.3f} мс")
            print(f"  Команда UART: {result['uart_command']}")
            return result['total_delay']
        else:
            print(f"✗ Ошибка расчета: {response.status_code}")
            return None
            
    def test_apply_delay(self, delay_ms):
        """Тест применения задержки"""
        print(f"\n--- Тест применения задержки: {delay_ms:.3f} мс ---")
        
        data = {
            'delay': delay_ms,
            'enable': True
        }
        
        response = self.session.post(f"{BASE_URL}/api/satellite_delay/apply", json=data)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✓ Задержка применена успешно")
            time.sleep(1)  # Ожидание обновления статуса
            return True
        else:
            print(f"✗ Ошибка применения: {response.status_code}")
            return False
            
    def test_get_status(self):
        """Тест получения статуса"""
        print("\n--- Тест получения статуса ---")
        
        response = self.session.get(f"{BASE_URL}/api/satellite_delay/status")
        
        if response.status_code == 200:
            status = response.json()
            print(f"✓ Статус получен успешно")
            print(f"  Включено: {status['enabled']}")
            print(f"  Задержка: {status['delay']} мс")
            print(f"  Активно: {status['active']}")
            print(f"  Текущее значение: {status['current_value']} мс")
            return status
        else:
            print(f"✗ Ошибка получения статуса: {response.status_code}")
            return None
            
    def run_all_tests(self):
        """Запуск всех тестов"""
        print("=== Запуск тестов API задержки спутника ===")
        
        # Тест 1: Получение текущей конфигурации
        status = self.test_get_status()
        if status:
            print("✓ Тест 1 пройден")
            
        # Тест 2: Установка задержки 119.5 мс и включение
        delay = self.test_calculate_delay()
        if delay and self.test_apply_delay(delay):
            print("✓ Тест 2 пройден")
            
        # Тест 3: Проверка, что статус отражает изменение
        status = self.test_get_status()
        if status and status['enabled'] and abs(status['delay'] - delay) < 0.001:
            print("✓ Тест 3 пройден")
            
        # Тест 4: Отключение компенсации
        response = self.session.post(f"{BASE_URL}/api/satellite_delay/apply", 
                                   json={'delay': delay, 'enable': False})
        if response.status_code == 200:
            print("✓ Тест 4 пройден")
            
        # Тест 5: Проверка, что статус показывает отключение
        status = self.test_get_status()
        if status and not status['enabled']:
            print("✓ Тест 5 пройден")
            
        # Тест 6: Тест граничных значений
        print("\n--- Тест граничных значений ---")
        
        # Тест минимального значения
        if self.test_apply_delay(0.001):
            print("✓ Минимальное значение принято")
            
        # Тест максимального значения
        if self.test_apply_delay(500.0):
            print("✓ Максимальное значение принято")
            
        # Тест точности (0.001 мс)
        if self.test_apply_delay(123.456):
            status = self.test_get_status()
            if status and abs(status['delay'] - 123.456) < 0.001:
                print("✓ Точность сохранена")
                
        # Сводка
        print("\n=== Сводка тестов ===")
        print("Все тесты завершены")

def main():
    tester = TestSatelliteDelayAPI()
    
    # Вход в систему
    tester.login()
    
    if not tester.logged_in:
        print("Не удалось войти в систему. Проверьте, что сервер запущен.")
        return
        
    # Запуск тестов
    tester.run_all_tests()

if __name__ == "__main__":
    # Проверка доступности сервера
    try:
        response = requests.get(f"{BASE_URL}/login", timeout=2)
        if response.status_code == 200:
            main()
        else:
            print(f"Сервер вернул статус {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"Не удалось подключиться к серверу: {e}")
        print("Убедитесь, что веб-интерфейс запущен на http://localhost:5000")