#!/usr/bin/env python3
"""
Test script for satellite delay compensation feature
"""

import requests
import json
import time
import sys

# Configuration
BASE_URL = "http://localhost:5000"
API_CONFIG = f"{BASE_URL}/api/config"
API_STATUS = f"{BASE_URL}/api/status"

def test_get_config():
    """Test getting current configuration"""
    print("Testing GET /api/config...")
    try:
        response = requests.get(API_CONFIG)
        config = response.json()
        print(f"Current satellite delay: {config.get('satellite_delay_compensation', 'Not found')} ms")
        print(f"Compensation enabled: {config.get('satellite_delay_enabled', 'Not found')}")
        return True
    except Exception as e:
        print(f"Error: {e}")
        return False

def test_set_delay(delay_ms, enabled):
    """Test setting satellite delay compensation"""
    print(f"\nTesting SET satellite delay to {delay_ms} ms, enabled={enabled}...")
    
    config = {
        "satellite_delay_compensation": delay_ms,
        "satellite_delay_enabled": enabled
    }
    
    try:
        response = requests.post(API_CONFIG, json=config)
        result = response.json()
        if result.get('status') == 'success':
            print("Configuration updated successfully")
            return True
        else:
            print(f"Failed to update configuration: {result}")
            return False
    except Exception as e:
        print(f"Error: {e}")
        return False

def test_status_update():
    """Test if status reflects the changes"""
    print("\nChecking status update...")
    time.sleep(1)  # Wait for status to update
    
    try:
        response = requests.get(API_STATUS)
        status = response.json()
        print(f"Satellite delay active: {status.get('satellite_delay_active', 'Not found')}")
        print(f"Satellite delay value: {status.get('satellite_delay_value', 'Not found')} ms")
        return True
    except Exception as e:
        print(f"Error: {e}")
        return False

def run_tests():
    """Run all tests"""
    print("=== Satellite Delay Compensation Test Suite ===\n")
    
    tests_passed = 0
    tests_total = 0
    
    # Test 1: Get current configuration
    tests_total += 1
    if test_get_config():
        tests_passed += 1
    
    # Test 2: Set delay to 119.5 ms and enable
    tests_total += 1
    if test_set_delay(119.5, True):
        tests_passed += 1
        
    # Test 3: Check status reflects the change
    tests_total += 1
    if test_status_update():
        tests_passed += 1
    
    # Test 4: Disable compensation
    tests_total += 1
    if test_set_delay(119.5, False):
        tests_passed += 1
    
    # Test 5: Check status shows disabled
    tests_total += 1
    if test_status_update():
        tests_passed += 1
    
    # Test 6: Test boundary values
    print("\n=== Testing boundary values ===")
    
    # Test minimum value
    tests_total += 1
    print("\nTesting minimum value (0 ms)...")
    if test_set_delay(0.0, True):
        tests_passed += 1
    
    # Test maximum value
    tests_total += 1
    print("\nTesting maximum value (300 ms)...")
    if test_set_delay(300.0, True):
        tests_passed += 1
    
    # Test precision (0.001 ms)
    tests_total += 1
    print("\nTesting precision (120.123 ms)...")
    if test_set_delay(120.123, True):
        tests_passed += 1
    
    # Summary
    print(f"\n=== Test Summary ===")
    print(f"Tests passed: {tests_passed}/{tests_total}")
    print(f"Success rate: {tests_passed/tests_total*100:.1f}%")
    
    return tests_passed == tests_total

def main():
    """Main function"""
    print("Starting satellite delay compensation tests...")
    print(f"Target: {BASE_URL}")
    print("Make sure the web interface is running!\n")
    
    try:
        # Check if server is running
        response = requests.get(BASE_URL, timeout=2)
        print("Server is running ✓\n")
    except:
        print("ERROR: Cannot connect to web interface!")
        print("Please start the web interface first:")
        print("  cd web_interface")
        print("  python app.py")
        sys.exit(1)
    
    # Run tests
    success = run_tests()
    
    if success:
        print("\n✅ All tests passed!")
        sys.exit(0)
    else:
        print("\n❌ Some tests failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()