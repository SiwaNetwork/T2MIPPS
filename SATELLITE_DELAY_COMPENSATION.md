# Satellite Delay Compensation

## Overview

This document describes the satellite delay compensation feature implemented in the T2MI PPS Generator system. This feature allows for precise compensation of signal propagation delays from geostationary satellites.

## Background

Geostationary satellites orbit at approximately 35,786 km above the Earth's equator. The signal propagation delay from these satellites to ground stations is significant and must be compensated for accurate timing applications.

### Typical Delay Values

- **Geostationary Satellite Delay**: ~119-120 ms (one-way)
- **Round-trip Delay**: ~238-240 ms
- **Variation**: ±1-2 ms depending on the exact location of the ground station

## Implementation

### Web Interface

The satellite delay compensation can be configured through the web interface:

1. Navigate to the **Configuration** section
2. Find the **Satellite Delay Compensation** subsection
3. Enter the delay value in milliseconds (typical: 119-120 ms)
4. Enable/disable the compensation using the toggle switch
5. Click **Save Configuration** to apply changes

### Configuration Parameters

- **satellite_delay_compensation**: Float value representing the delay in milliseconds
  - Range: 0-300 ms
  - Precision: 0.001 ms (1 microsecond)
  - Default: 0.0 ms

- **satellite_delay_enabled**: Boolean flag to enable/disable compensation
  - Default: false (disabled)

### UART Commands

The following UART commands are used to control the satellite delay compensation:

```
SET_SAT_DELAY:<value>    # Set delay compensation value in milliseconds
SET_SAT_DELAY_EN:<0|1>   # Enable (1) or disable (0) compensation
```

### Status Monitoring

The current status of satellite delay compensation is displayed in the dashboard:

- **Status Badge**: Shows "Active" (blue) or "Disabled" (gray)
- **Delay Value**: Displays the current compensation value when active

## Technical Details

### Signal Processing

When enabled, the system applies the following compensation:

1. **Input Signal Timing**: The received signal timestamp is adjusted by subtracting the configured delay value
2. **PPS Generation**: The PPS output is generated based on the compensated time
3. **T2MI Packet Timing**: T2MI packets are timestamped using the compensated time reference

### Calculation Example

```
Actual Signal Reception Time: T_received
Configured Delay: D_satellite (e.g., 119.5 ms)
Compensated Time: T_compensated = T_received - D_satellite
```

### Precision Considerations

- The compensation is applied with microsecond precision
- The DPLL (Digital Phase-Locked Loop) maintains phase alignment after compensation
- Temperature compensation remains active and independent of satellite delay compensation

## Use Cases

1. **DVB-T2 Single Frequency Networks (SFN)**
   - Ensures all transmitters in the network are synchronized
   - Compensates for different satellite feed delays

2. **Precision Timing Applications**
   - Scientific measurements requiring accurate absolute time
   - Synchronization of distributed systems

3. **Broadcast Applications**
   - Maintaining lip-sync in video/audio streams
   - Coordinating multiple transmission sites

## Best Practices

1. **Measurement**: Measure the actual delay in your specific installation
   - Use GPS timing reference for comparison
   - Account for all signal processing delays in the chain

2. **Verification**: After enabling compensation:
   - Monitor the phase error to ensure stability
   - Check DPLL lock status
   - Verify T2MI packet timing

3. **Documentation**: Keep records of:
   - Measured delay values
   - Satellite orbital position
   - Ground station location

## Troubleshooting

### Common Issues

1. **DPLL Loses Lock After Enabling Compensation**
   - Solution: Gradually adjust the delay value in small increments
   - Allow the DPLL to re-lock between adjustments

2. **Incorrect Delay Value**
   - Symptom: Persistent phase error or timing offset
   - Solution: Re-measure the actual delay using external reference

3. **Status Not Updating**
   - Check UART connection
   - Verify FPGA firmware supports satellite delay commands

### Debug Commands

Use the command interface to query current settings:
```
GET_SAT_DELAY     # Returns current delay value
GET_SAT_DELAY_EN  # Returns enable/disable status
```

## API Reference

### REST API Endpoints

**GET /api/config**
Returns current configuration including:
```json
{
  "satellite_delay_compensation": 119.5,
  "satellite_delay_enabled": true,
  ...
}
```

**POST /api/config**
Update configuration:
```json
{
  "satellite_delay_compensation": 120.0,
  "satellite_delay_enabled": true
}
```

### WebSocket Updates

Real-time status updates include:
```json
{
  "satellite_delay_active": true,
  "satellite_delay_value": 120.0,
  ...
}
```

## Future Enhancements

1. **Automatic Delay Calculation**
   - Based on satellite position and ground station coordinates
   - Integration with TLE (Two-Line Element) data

2. **Multiple Satellite Support**
   - Profile management for different satellites
   - Quick switching between configurations

3. **Delay Variation Compensation**
   - Account for orbital perturbations
   - Seasonal variations in propagation delay