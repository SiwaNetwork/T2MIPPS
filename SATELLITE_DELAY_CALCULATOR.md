# Satellite Delay Calculator

## Overview

The Satellite Delay Calculator is a web-based tool integrated into the T2MI PPS Generator system that calculates propagation delays for satellite communication links. It provides accurate delay compensation values that can be applied to the CAM module to ensure proper signal synchronization.

## Features

- **Accurate Delay Calculation**: Computes propagation delays with all atmospheric corrections
- **Interactive Web Interface**: User-friendly form for entering station coordinates and satellite parameters
- **Real-time Visualization**: Interactive map showing transmitter, receiver, and satellite positions
- **Direct CAM Integration**: One-click application of calculated delay values to the CAM module
- **Multiple Corrections**: Accounts for tropospheric and ionospheric delays

## Physical Model

### Components of Delay

1. **Free Space Propagation Delay**
   - Primary component based on distance and speed of light
   - Calculated for both uplink (TX → Satellite) and downlink (Satellite → RX)

2. **Tropospheric Delay**
   - Caused by refraction in the lower atmosphere
   - Varies with elevation angle and altitude
   - Typical values: 2-10 meters (6-30 μs)

3. **Ionospheric Delay**
   - Frequency-dependent delay in the ionosphere
   - More significant at lower frequencies
   - Typical values at Ku-band: 0.1-1 meter (0.3-3 μs)

### Constants Used

- Speed of light: 299,792,458 m/s
- Earth radius: 6,371 km (mean)
- GEO altitude: 35,786 km
- Troposphere height: 11 km
- Ionosphere F2 layer: 350 km

## Usage

### Web Interface

1. Navigate to the Satellite Delay Calculator page from the main dashboard
2. Enter transmitter station coordinates:
   - Latitude (degrees, -90 to +90)
   - Longitude (degrees, -180 to +180)
   - Altitude (meters above sea level)

3. Enter receiver station coordinates:
   - Latitude (degrees, -90 to +90)
   - Longitude (degrees, -180 to +180)
   - Altitude (meters above sea level)

4. Enter satellite parameters:
   - Satellite longitude (degrees East)
   - Signal frequency (GHz)

5. Click "Calculate Delay" to compute the propagation delay

6. Review the results:
   - Total delay (ms)
   - Component breakdown
   - Elevation angles
   - Distance measurements

7. Apply to CAM module:
   - Click "Apply to CAM Module" to send the compensation value
   - The system will execute: `set_sat_delay <value_in_microseconds>`

### API Endpoints

#### Calculate Delay
```
POST /api/calculate_satellite_delay
Content-Type: application/json

{
  "tx_lat": 55.7558,
  "tx_lon": 37.6173,
  "tx_alt": 150,
  "rx_lat": 59.9311,
  "rx_lon": 30.3609,
  "rx_alt": 50,
  "sat_lon": 13.0,
  "frequency": 12000000000
}
```

Response:
```json
{
  "success": true,
  "data": {
    "total_delay": 262.813,
    "uplink_delay": 131.027,
    "downlink_delay": 131.786,
    "compensation_value": 262813,
    "uart_command": "set_sat_delay 262813"
  }
}
```

#### Apply Delay
```
POST /api/set_satellite_delay
Content-Type: application/json

{
  "delay_us": 262813
}
```

## Typical Values

### Geostationary Satellites (GEO)
- Altitude: 35,786 km
- One-way delay: 119.5 ± 2 ms
- Round-trip delay: 239 ± 4 ms

### Medium Earth Orbit (MEO)
- Altitude: 8,000-20,000 km
- One-way delay: 40-80 ms

### Low Earth Orbit (LEO)
- Altitude: 500-2,000 km
- One-way delay: 3-10 ms

## Example Calculations

### Moscow to St. Petersburg via Eutelsat 13E
- TX: Moscow (55.76°N, 37.62°E)
- RX: St. Petersburg (59.93°N, 30.36°E)
- Satellite: 13°E
- Total delay: ~263 ms
- Compensation: 263000 μs

### Long Distance: Moscow to Vladivostok
- TX: Moscow (55.76°N, 37.62°E)
- RX: Vladivostok (43.12°N, 131.89°E)
- Satellite: 140°E
- Total delay: ~271 ms
- Compensation: 271000 μs

## Technical Implementation

The calculator uses:
- Spherical Earth model for distance calculations
- Simplified tropospheric model with mapping functions
- Ionospheric delay based on Total Electron Content (TEC)
- WGS84 coordinate system

## Limitations

1. Assumes geostationary satellites at exactly 0° latitude
2. Uses simplified atmospheric models
3. Does not account for:
   - Satellite motion/drift
   - Multipath effects
   - Equipment delays
   - Weather-specific variations

## Integration with T2MI System

The calculated delay value is used to compensate for satellite propagation delay in the T2MI stream timing. This ensures that:
- PPS signals arrive synchronized at the receiver
- T2MI timestamps are properly aligned
- SFN synchronization is maintained across the network

## Troubleshooting

### Common Issues

1. **Negative elevation angles**: Station cannot see the satellite (below horizon)
2. **Very large delays**: Check coordinate signs (N/S, E/W)
3. **UART communication fails**: Verify CAM module connection
4. **Unrealistic values**: Ensure altitude is in meters, not feet

### Validation

To validate calculations:
1. Check elevation angles (should be positive for visible satellites)
2. Verify distances are reasonable (35,786-42,000 km for GEO)
3. Compare with typical values (119.5 ms one-way for GEO)