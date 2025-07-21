#!/usr/bin/env python3
"""
Satellite Delay Calculator
Calculates propagation delay for geostationary satellite communication
Including all corrections and constants
"""

import math
from typing import Tuple, Dict

class SatelliteDelayCalculator:
    """
    Calculate satellite propagation delay with all corrections
    """
    
    # Physical constants
    SPEED_OF_LIGHT = 299792458.0  # m/s in vacuum
    EARTH_RADIUS = 6371000.0  # meters (mean radius)
    GEO_ALTITUDE = 35786000.0  # meters (geostationary orbit altitude)
    GEO_RADIUS = EARTH_RADIUS + GEO_ALTITUDE  # meters
    
    # Atmospheric corrections
    TROPOSPHERE_HEIGHT = 11000.0  # meters
    IONOSPHERE_HEIGHT = 350000.0  # meters (F2 layer peak)
    
    # Refractive indices
    TROPOSPHERE_REFRACTIVE_INDEX = 1.000325  # at sea level
    IONOSPHERE_DELAY_FACTOR = 0.002  # typical ionospheric delay factor
    
    def __init__(self):
        """Initialize calculator"""
        self.last_calculation = None
    
    def deg_to_rad(self, degrees: float) -> float:
        """Convert degrees to radians"""
        return math.radians(degrees)
    
    def calculate_distance(self, lat1: float, lon1: float, alt1: float,
                          lat2: float, lon2: float, alt2: float) -> float:
        """
        Calculate 3D distance between two points
        
        Args:
            lat1, lon1: Latitude and longitude of point 1 (degrees)
            alt1: Altitude of point 1 (meters)
            lat2, lon2: Latitude and longitude of point 2 (degrees)
            alt2: Altitude of point 2 (meters)
            
        Returns:
            Distance in meters
        """
        # Convert to radians
        lat1_rad = self.deg_to_rad(lat1)
        lon1_rad = self.deg_to_rad(lon1)
        lat2_rad = self.deg_to_rad(lat2)
        lon2_rad = self.deg_to_rad(lon2)
        
        # Convert to Cartesian coordinates
        r1 = self.EARTH_RADIUS + alt1
        x1 = r1 * math.cos(lat1_rad) * math.cos(lon1_rad)
        y1 = r1 * math.cos(lat1_rad) * math.sin(lon1_rad)
        z1 = r1 * math.sin(lat1_rad)
        
        r2 = self.EARTH_RADIUS + alt2
        x2 = r2 * math.cos(lat2_rad) * math.cos(lon2_rad)
        y2 = r2 * math.cos(lat2_rad) * math.sin(lon2_rad)
        z2 = r2 * math.sin(lat2_rad)
        
        # Calculate distance
        distance = math.sqrt((x2 - x1)**2 + (y2 - y1)**2 + (z2 - z1)**2)
        return distance
    
    def calculate_elevation_angle(self, ground_lat: float, ground_lon: float,
                                 sat_lon: float) -> float:
        """
        Calculate elevation angle from ground station to satellite
        
        Args:
            ground_lat: Ground station latitude (degrees)
            ground_lon: Ground station longitude (degrees)
            sat_lon: Satellite longitude (degrees)
            
        Returns:
            Elevation angle in degrees
        """
        # Convert to radians
        lat_rad = self.deg_to_rad(ground_lat)
        lon_diff_rad = self.deg_to_rad(sat_lon - ground_lon)
        
        # Calculate angle between ground station and satellite
        cos_angle = math.cos(lat_rad) * math.cos(lon_diff_rad)
        
        # Calculate elevation angle
        numerator = cos_angle - self.EARTH_RADIUS / self.GEO_RADIUS
        denominator = math.sqrt(1 - cos_angle**2)
        
        if denominator == 0:
            elevation_rad = math.pi / 2
        else:
            elevation_rad = math.atan(numerator / denominator)
        
        elevation_deg = math.degrees(elevation_rad)
        return elevation_deg
    
    def calculate_tropospheric_delay(self, elevation_angle: float, altitude: float) -> float:
        """
        Calculate tropospheric delay
        
        Args:
            elevation_angle: Elevation angle in degrees
            altitude: Station altitude in meters
            
        Returns:
            Tropospheric delay in meters
        """
        # Simplified tropospheric model
        elevation_rad = self.deg_to_rad(elevation_angle)
        
        # Zenith delay (vertical path) - typical values
        # Dry component: ~2.3m at sea level
        # Wet component: ~0.1m (variable)
        pressure_factor = math.exp(-altitude / 8000.0)  # Pressure decreases with altitude
        dry_zenith_delay = 2.3 * pressure_factor  # meters
        wet_zenith_delay = 0.1 * pressure_factor  # meters
        total_zenith_delay = dry_zenith_delay + wet_zenith_delay
        
        # Mapping function for elevation angle
        if elevation_angle > 5:
            mapping_function = 1.0 / math.sin(elevation_rad)
        else:
            # For low elevation angles, use more sophisticated mapping
            # Niell mapping function approximation
            a = 0.00143
            b = 0.0445
            c = 0.0
            sin_el = math.sin(elevation_rad)
            mapping_function = (1 + a / (1 + b / (1 + c))) / \
                             (sin_el + a / (sin_el + b / (sin_el + c)))
        
        tropospheric_delay = total_zenith_delay * mapping_function
        return tropospheric_delay
    
    def calculate_ionospheric_delay(self, elevation_angle: float, frequency: float = 12e9) -> float:
        """
        Calculate ionospheric delay
        
        Args:
            elevation_angle: Elevation angle in degrees
            frequency: Signal frequency in Hz (default 12 GHz for Ku-band)
            
        Returns:
            Ionospheric delay in meters
        """
        # Simplified ionospheric model
        elevation_rad = self.deg_to_rad(elevation_angle)
        
        # Vertical TEC (Total Electron Content) - typical value
        vertical_tec = 50  # TECU (10^16 electrons/m^2)
        
        # Frequency-dependent factor (40.3 / f^2) where f is in Hz
        # Result is in meters per TECU
        frequency_factor = 40.3 / (frequency**2) * 1e16
        
        # Obliquity factor
        re_factor = self.EARTH_RADIUS / (self.EARTH_RADIUS + self.IONOSPHERE_HEIGHT)
        if math.cos(elevation_rad) > re_factor:
            obliquity_factor = 1.0 / math.sqrt(1 - (re_factor * math.sin(elevation_rad))**2)
        else:
            obliquity_factor = 3.0  # Maximum reasonable value
        
        ionospheric_delay = vertical_tec * frequency_factor * obliquity_factor
        return ionospheric_delay
    
    def calculate_satellite_delay(self, tx_lat: float, tx_lon: float, tx_alt: float,
                                 rx_lat: float, rx_lon: float, rx_alt: float,
                                 sat_lon: float, frequency: float = 12e9) -> Dict:
        """
        Calculate total satellite propagation delay with all corrections
        
        Args:
            tx_lat, tx_lon: Transmitter latitude and longitude (degrees)
            tx_alt: Transmitter altitude (meters)
            rx_lat, rx_lon: Receiver latitude and longitude (degrees)
            rx_alt: Receiver altitude (meters)
            sat_lon: Satellite longitude (degrees)
            frequency: Signal frequency in Hz
            
        Returns:
            Dictionary with delay components and total delay
        """
        # Calculate distances
        uplink_distance = self.calculate_distance(
            tx_lat, tx_lon, tx_alt,
            0.0, sat_lon, self.GEO_ALTITUDE  # Satellite at equator
        )
        
        downlink_distance = self.calculate_distance(
            0.0, sat_lon, self.GEO_ALTITUDE,  # Satellite at equator
            rx_lat, rx_lon, rx_alt
        )
        
        # Calculate elevation angles
        tx_elevation = self.calculate_elevation_angle(tx_lat, tx_lon, sat_lon)
        rx_elevation = self.calculate_elevation_angle(rx_lat, rx_lon, sat_lon)
        
        # Calculate atmospheric delays
        tx_tropo_delay = self.calculate_tropospheric_delay(tx_elevation, tx_alt)
        rx_tropo_delay = self.calculate_tropospheric_delay(rx_elevation, rx_alt)
        
        tx_iono_delay = self.calculate_ionospheric_delay(tx_elevation, frequency)
        rx_iono_delay = self.calculate_ionospheric_delay(rx_elevation, frequency)
        
        # Total path length with corrections
        total_distance = uplink_distance + downlink_distance + \
                        tx_tropo_delay + rx_tropo_delay + \
                        tx_iono_delay + rx_iono_delay
        
        # Calculate delays
        free_space_delay = (uplink_distance + downlink_distance) / self.SPEED_OF_LIGHT
        tropospheric_delay = (tx_tropo_delay + rx_tropo_delay) / self.SPEED_OF_LIGHT
        ionospheric_delay = (tx_iono_delay + rx_iono_delay) / self.SPEED_OF_LIGHT
        
        total_delay = total_distance / self.SPEED_OF_LIGHT
        
        # Store results
        # Note: total_delay is the sum of uplink + downlink delays (full path through satellite)
        self.last_calculation = {
            'uplink_distance': uplink_distance,
            'downlink_distance': downlink_distance,
            'total_distance': total_distance,
            'tx_elevation': tx_elevation,
            'rx_elevation': rx_elevation,
            'free_space_delay': free_space_delay * 1000,  # Convert to ms
            'tropospheric_delay': tropospheric_delay * 1000,  # Convert to ms
            'ionospheric_delay': ionospheric_delay * 1000,  # Convert to ms
            'total_delay': total_delay * 1000,  # Total delay in ms (TX->SAT->RX)
            'uplink_delay': (uplink_distance + tx_tropo_delay + tx_iono_delay) / self.SPEED_OF_LIGHT * 1000,  # ms
            'downlink_delay': (downlink_distance + rx_tropo_delay + rx_iono_delay) / self.SPEED_OF_LIGHT * 1000,  # ms
            'one_way_delay': total_delay * 1000,  # One-way delay in ms (same as total_delay)
            'round_trip_delay': total_delay * 2000,  # Round-trip delay in ms
            'compensation_value': int(total_delay * 1e6),  # Compensation value in microseconds
            'uart_command': f"set_sat_delay {int(total_delay * 1e6)}"  # UART command
        }
        
        return self.last_calculation
    
    def get_typical_delays(self) -> Dict:
        """
        Get typical delay values for reference
        
        Returns:
            Dictionary with typical delay values
        """
        return {
            'geo_typical_one_way': 119.5,  # ms
            'geo_typical_variation': 2.0,  # ms
            'leo_typical_one_way': 5.0,  # ms
            'meo_typical_one_way': 40.0,  # ms
        }