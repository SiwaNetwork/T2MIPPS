#!/usr/bin/env python3
"""
Калькулятор задержки спутника для генератора T2MI PPS
Рассчитывает задержку распространения сигнала через геостационарный спутник
с учетом атмосферных эффектов
"""

import math
import numpy as np
from typing import Tuple, Dict

class SatelliteDelayCalculator:
    """
    Рассчитывает задержку распространения сигнала через геостационарный спутник
    """
    
    # Физические константы
    SPEED_OF_LIGHT = 299792458.0  # м/с в вакууме
    EARTH_RADIUS = 6371000.0  # метры (средний радиус)
    GEO_ALTITUDE = 35786000.0  # метры (высота геостационарной орбиты)
    GEO_RADIUS = EARTH_RADIUS + GEO_ALTITUDE  # метры
    
    # Атмосферные поправки
    TROPOSPHERE_HEIGHT = 11000.0  # метры
    IONOSPHERE_HEIGHT = 350000.0  # метры (пик слоя F2)
    
    # Показатели преломления
    TROPOSPHERE_REFRACTIVE_INDEX = 1.000325  # на уровне моря
    IONOSPHERE_DELAY_FACTOR = 0.002  # типичный фактор ионосферной задержки
    
    def __init__(self):
        """Инициализация калькулятора"""
        pass
    
    def calculate_distance(self, lat1: float, lon1: float, alt1: float,
                         lat2: float, lon2: float, alt2: float) -> float:
        """
        Рассчитывает расстояние между двумя точками в 3D пространстве
        
        Аргументы:
            lat1, lon1: Широта и долгота первой точки (градусы)
            alt1: Высота первой точки (метры)
            lat2, lon2: Широта и долгота второй точки (градусы)
            alt2: Высота второй точки (метры)
            
        Возвращает:
            Расстояние в метрах
        """
        # Преобразование в радианы
        lat1_rad = math.radians(lat1)
        lon1_rad = math.radians(lon1)
        lat2_rad = math.radians(lat2)
        lon2_rad = math.radians(lon2)
        
        # Преобразование в декартовы координаты
        r1 = self.EARTH_RADIUS + alt1
        x1 = r1 * math.cos(lat1_rad) * math.cos(lon1_rad)
        y1 = r1 * math.cos(lat1_rad) * math.sin(lon1_rad)
        z1 = r1 * math.sin(lat1_rad)
        
        r2 = self.EARTH_RADIUS + alt2
        x2 = r2 * math.cos(lat2_rad) * math.cos(lon2_rad)
        y2 = r2 * math.cos(lat2_rad) * math.sin(lon2_rad)
        z2 = r2 * math.sin(lat2_rad)
        
        # Расчет расстояния
        distance = math.sqrt((x2-x1)**2 + (y2-y1)**2 + (z2-z1)**2)
        
        return distance
    
    def calculate_elevation_angle(self, ground_lat: float, ground_lon: float, 
                                ground_alt: float, sat_lon: float) -> float:
        """
        Рассчитывает угол места спутника относительно наземной станции
        
        Аргументы:
            ground_lat, ground_lon: Широта и долгота наземной станции (градусы)
            ground_alt: Высота наземной станции (метры)
            sat_lon: Долгота спутника (градусы)
            
        Возвращает:
            Угол места в градусах
        """
        # Преобразование в радианы
        lat_rad = math.radians(ground_lat)
        lon_diff_rad = math.radians(sat_lon - ground_lon)
        
        # Расчет угла между наземной станцией и спутником
        cos_angle = math.cos(lat_rad) * math.cos(lon_diff_rad)
        
        # Расчет угла места
        r_ground = self.EARTH_RADIUS + ground_alt
        numerator = self.GEO_RADIUS - r_ground * cos_angle
        denominator = math.sqrt(self.GEO_RADIUS**2 + r_ground**2 - 
                               2 * self.GEO_RADIUS * r_ground * cos_angle)
        
        elevation_rad = math.asin(numerator / denominator)
        elevation_deg = math.degrees(elevation_rad)
        
        return elevation_deg
    
    def calculate_tropospheric_delay(self, elevation_deg: float, altitude: float) -> float:
        """
        Рассчитывает тропосферную задержку
        
        Аргументы:
            elevation_deg: Угол места в градусах
            altitude: Высота станции в метрах
            
        Возвращает:
            Тропосферная задержка в метрах
        """
        # Упрощенная тропосферная модель
        elevation_rad = math.radians(elevation_deg)
        
        # Зенитная задержка (вертикальный путь) - типичные значения
        # Сухая компонента: ~2.3м на уровне моря
        # Влажная компонента: ~0.1м (переменная)
        pressure_factor = math.exp(-altitude / 8000.0)  # Давление уменьшается с высотой
        dry_zenith_delay = 2.3 * pressure_factor  # метры
        wet_zenith_delay = 0.1 * pressure_factor  # метры
        
        zenith_delay = dry_zenith_delay + wet_zenith_delay
        
        # Функция отображения для угла места
        if elevation_deg > 5:
            mapping_factor = 1.0 / math.sin(elevation_rad)
        else:
            # Для малых углов места используем более сложное отображение
            # Аппроксимация функции отображения Нилла
            a = 0.00143
            b = 0.0445
            c = 0.0
            mapping_factor = 1.0 / (math.sin(elevation_rad) + 
                                   a / (math.tan(elevation_rad) + b))
        
        tropospheric_delay = zenith_delay * mapping_factor
        
        return tropospheric_delay
    
    def calculate_ionospheric_delay(self, elevation_deg: float, frequency_hz: float = 12e9) -> float:
        """
        Рассчитывает ионосферную задержку
        
        Аргументы:
            elevation_deg: Угол места в градусах
            frequency_hz: Частота сигнала в Гц (по умолчанию 12 ГГц для Ku-диапазона)
            
        Возвращает:
            Ионосферная задержка в метрах
        """
        # Упрощенная ионосферная модель
        elevation_rad = math.radians(elevation_deg)
        
        # Вертикальное TEC (Полное электронное содержание) - типичное значение
        vertical_tec = 50  # TECU (10^16 электронов/м^2)
        
        # Частотно-зависимый фактор (40.3 / f^2) где f в Гц
        # Результат в метрах на TECU
        frequency_factor = 40.3e16 / (frequency_hz ** 2)
        
        # Фактор наклонности
        earth_radius_km = self.EARTH_RADIUS / 1000
        ionosphere_height_km = self.IONOSPHERE_HEIGHT / 1000
        
        obliquity_factor = 1.0 / math.sqrt(1 - (earth_radius_km * math.cos(elevation_rad) / 
                                               (earth_radius_km + ionosphere_height_km))**2)
        
        if obliquity_factor > 3.0:
            obliquity_factor = 3.0  # Максимальное разумное значение
        
        ionospheric_delay = vertical_tec * frequency_factor * obliquity_factor
        
        return ionospheric_delay
    
    def calculate_delay(self, tx_lat: float, tx_lon: float, tx_alt: float,
                       rx_lat: float, rx_lon: float, rx_alt: float,
                       sat_lon: float, frequency_hz: float = 12e9) -> Dict[str, float]:
        """
        Рассчитывает полную задержку распространения сигнала через спутник
        
        Аргументы:
            tx_lat, tx_lon, tx_alt: Координаты передатчика
            rx_lat, rx_lon, rx_alt: Координаты приемника
            sat_lon: Долгота спутника
            frequency_hz: Частота сигнала (по умолчанию 12 ГГц)
            
        Возвращает:
            Словарь с компонентами задержки
        """
        # Расчет расстояний
        uplink_distance = self.calculate_distance(
            tx_lat, tx_lon, tx_alt,
            0.0, sat_lon, self.GEO_ALTITUDE  # Спутник на экваторе
        )
        
        downlink_distance = self.calculate_distance(
            0.0, sat_lon, self.GEO_ALTITUDE,  # Спутник на экваторе
            rx_lat, rx_lon, rx_alt
        )
        
        # Расчет углов места
        tx_elevation = self.calculate_elevation_angle(tx_lat, tx_lon, tx_alt, sat_lon)
        rx_elevation = self.calculate_elevation_angle(rx_lat, rx_lon, rx_alt, sat_lon)
        
        # Расчет атмосферных задержек
        tx_tropo_delay = self.calculate_tropospheric_delay(tx_elevation, tx_alt)
        rx_tropo_delay = self.calculate_tropospheric_delay(rx_elevation, rx_alt)
        
        tx_iono_delay = self.calculate_ionospheric_delay(tx_elevation, frequency_hz)
        rx_iono_delay = self.calculate_ionospheric_delay(rx_elevation, frequency_hz)
        
        # Полная длина пути с поправками
        total_distance = uplink_distance + downlink_distance
        tropospheric_delay = tx_tropo_delay + rx_tropo_delay
        ionospheric_delay = tx_iono_delay + rx_iono_delay
        
        # Расчет задержек
        free_space_delay = total_distance / self.SPEED_OF_LIGHT
        atmospheric_delay = (tropospheric_delay + ionospheric_delay) / self.SPEED_OF_LIGHT
        total_delay = free_space_delay + atmospheric_delay
        
        # Сохранение результатов
        # Примечание: total_delay - это сумма задержек восходящей + нисходящей линий (полный путь через спутник)
        return {
            'uplink_distance': uplink_distance,
            'downlink_distance': downlink_distance,
            'total_distance': total_distance,
            'tx_elevation': tx_elevation,
            'rx_elevation': rx_elevation,
            'free_space_delay': free_space_delay * 1000,  # Преобразование в мс
            'tropospheric_delay': tropospheric_delay * 1000,  # Преобразование в мс
            'ionospheric_delay': ionospheric_delay * 1000,  # Преобразование в мс
            'total_delay': total_delay * 1000,  # Полная задержка в мс (TX->SAT->RX)
            'uplink_delay': (uplink_distance + tx_tropo_delay + tx_iono_delay) / self.SPEED_OF_LIGHT * 1000,  # мс
            'downlink_delay': (downlink_distance + rx_tropo_delay + rx_iono_delay) / self.SPEED_OF_LIGHT * 1000,  # мс
            'one_way_delay': total_delay * 1000,  # Односторонняя задержка в мс (то же, что total_delay)
            'round_trip_delay': total_delay * 2000,  # Задержка туда-обратно в мс
            'compensation_value': int(total_delay * 1e6),  # Значение компенсации в микросекундах
            'uart_command': f"set_sat_delay {int(total_delay * 1e6)}"  # Команда UART
        }
    
    def get_typical_delays(self) -> Dict[str, float]:
        """
        Возвращает типичные значения задержек для различных сценариев
        
        Возвращает:
            Словарь с типичными задержками в миллисекундах
        """
        return {
            'geo_typical_one_way': 119.5,  # мс
            'geo_typical_variation': 2.0,  # мс
            'leo_typical_one_way': 5.0,  # мс
            'meo_typical_one_way': 40.0,  # мс
        }