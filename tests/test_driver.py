#!/usr/bin/env python3
"""
test_driver.py - Functional testing harness for Linux device drivers

This script provides comprehensive testing of device driver functionality including:
- Module loading/unloading (insmod/rmmod)
- Device node creation and permissions
- Basic I/O operations (open, read, write, close)
- Error handling and edge cases

Usage: python3 tests/test_driver.py [module_name]
"""

import os
import sys
import json
import subprocess
import tempfile
import time
from pathlib import Path

# Optional pytest import
try:
    import pytest
    PYTEST_AVAILABLE = True
except ImportError:
    PYTEST_AVAILABLE = False

class DeviceDriverTester:
    def __init__(self, module_path, device_name=None):
        """Initialize the driver tester."""
        self.module_path = Path(module_path)
        self.module_name = self.module_path.stem
        self.device_name = device_name or self.module_name
        self.device_path = f"/dev/{self.device_name}"
        self.test_results = {
            "module_path": str(module_path),
            "device_name": self.device_name,
            "tests": {},
            "summary": {
                "total_tests": 0,
                "passed": 0,
                "failed": 0,
                "score": 0
            }
        }
        
    def run_command(self, command, timeout=30):
        """Execute a shell command safely."""
        try:
            result = subprocess.run(
                command, 
                shell=True, 
                capture_output=True, 
                text=True, 
                timeout=timeout
            )
            return result.returncode, result.stdout, result.stderr
        except subprocess.TimeoutExpired:
            return -1, "", "Command timed out"
        except Exception as e:
            return -1, "", str(e)
    
    def is_module_loaded(self):
        """Check if the module is currently loaded."""
        returncode, stdout, stderr = self.run_command(f"lsmod | grep {self.module_name}")
        return returncode == 0
    
    def test_module_load(self):
        """Test module loading functionality."""
        test_name = "module_load"
        print(f"🔧 Testing module load: {self.module_path}")
        
        # Ensure module is not loaded
        if self.is_module_loaded():
            self.run_command(f"sudo rmmod {self.module_name}")
        
        # Test loading
        returncode, stdout, stderr = self.run_command(f"sudo insmod {self.module_path}")
        
        if returncode == 0:
            # Verify module is actually loaded
            if self.is_module_loaded():
                self.test_results["tests"][test_name] = {
                    "status": "PASS",
                    "message": "Module loaded successfully",
                    "score": 5
                }
                print("  ✅ Module load: PASS")
                return True
            else:
                self.test_results["tests"][test_name] = {
                    "status": "FAIL",
                    "message": "Module not found in lsmod after insmod",
                    "score": 0
                }
        else:
            self.test_results["tests"][test_name] = {
                "status": "FAIL",
                "message": f"insmod failed: {stderr}",
                "score": 0
            }
        
        print("  ❌ Module load: FAIL")
        return False
    
    def test_device_node_creation(self):
        """Test device node creation."""
        test_name = "device_node_creation"
        print(f"🔧 Testing device node: {self.device_path}")
        
        # Wait a moment for device to be created
        time.sleep(1)
        
        if os.path.exists(self.device_path):
            # Check if it's a character device
            stat_info = os.stat(self.device_path)
            if os.path.stat.S_ISCHR(stat_info.st_mode):
                self.test_results["tests"][test_name] = {
                    "status": "PASS",
                    "message": f"Character device {self.device_path} created successfully",
                    "score": 3
                }
                print("  ✅ Device node creation: PASS")
                return True
            else:
                self.test_results["tests"][test_name] = {
                    "status": "FAIL",
                    "message": f"{self.device_path} exists but is not a character device",
                    "score": 0
                }
        else:
            self.test_results["tests"][test_name] = {
                "status": "FAIL",
                "message": f"Device node {self.device_path} not created",
                "score": 0
            }
        
        print("  ❌ Device node creation: FAIL")
        return False
    
    def test_device_open_close(self):
        """Test device open and close operations."""
        test_name = "device_open_close"
        print(f"🔧 Testing device open/close: {self.device_path}")
        
        try:
            # Test opening the device
            with open(self.device_path, 'r+b') as device:
                self.test_results["tests"][test_name] = {
                    "status": "PASS",
                    "message": "Device opened and closed successfully",
                    "score": 2
                }
                print("  ✅ Device open/close: PASS")
                return True
        except PermissionError:
            self.test_results["tests"][test_name] = {
                "status": "FAIL",
                "message": "Permission denied (try running as root)",
                "score": 0
            }
        except FileNotFoundError:
            self.test_results["tests"][test_name] = {
                "status": "FAIL",
                "message": f"Device {self.device_path} not found",
                "score": 0
            }
        except Exception as e:
            self.test_results["tests"][test_name] = {
                "status": "FAIL",
                "message": f"Open failed: {str(e)}",
                "score": 0
            }
        
        print("  ❌ Device open/close: FAIL")
        return False
    
    def test_device_read(self):
        """Test device read operations."""
        test_name = "device_read"
        print(f"🔧 Testing device read: {self.device_path}")
        
        try:
            with open(self.device_path, 'rb') as device:
                data = device.read(1024)
                if data:
                    self.test_results["tests"][test_name] = {
                        "status": "PASS",
                        "message": f"Read {len(data)} bytes successfully",
                        "score": 2
                    }
                    print(f"  ✅ Device read: PASS ({len(data)} bytes)")
                    return True
                else:
                    self.test_results["tests"][test_name] = {
                        "status": "PARTIAL",
                        "message": "Read succeeded but returned no data",
                        "score": 1
                    }
                    print("  ⚠️ Device read: PARTIAL (no data)")
                    return False
        except PermissionError:
            self.test_results["tests"][test_name] = {
                "status": "FAIL",
                "message": "Permission denied (try running as root)",
                "score": 0
            }
        except Exception as e:
            self.test_results["tests"][test_name] = {
                "status": "FAIL",
                "message": f"Read failed: {str(e)}",
                "score": 0
            }
        
        print("  ❌ Device read: FAIL")
        return False
    
    def test_device_write(self):
        """Test device write operations."""
        test_name = "device_write"
        print(f"🔧 Testing device write: {self.device_path}")
        
        test_data = b"Hello, Device Driver Test!"
        
        try:
            with open(self.device_path, 'wb') as device:
                bytes_written = device.write(test_data)
                if bytes_written == len(test_data):
                    self.test_results["tests"][test_name] = {
                        "status": "PASS",
                        "message": f"Wrote {bytes_written} bytes successfully",
                        "score": 2
                    }
                    print(f"  ✅ Device write: PASS ({bytes_written} bytes)")
                    return True
                else:
                    self.test_results["tests"][test_name] = {
                        "status": "PARTIAL",
                        "message": f"Partial write: {bytes_written}/{len(test_data)} bytes",
                        "score": 1
                    }
                    print(f"  ⚠️ Device write: PARTIAL ({bytes_written}/{len(test_data)} bytes)")
                    return False
        except PermissionError:
            self.test_results["tests"][test_name] = {
                "status": "FAIL",
                "message": "Permission denied (try running as root)",
                "score": 0
            }
        except Exception as e:
            self.test_results["tests"][test_name] = {
                "status": "FAIL",
                "message": f"Write failed: {str(e)}",
                "score": 0
            }
        
        print("  ❌ Device write: FAIL")
        return False
    
    def test_read_write_consistency(self):
        """Test write-then-read consistency."""
        test_name = "read_write_consistency"
        print(f"🔧 Testing read/write consistency: {self.device_path}")
        
        test_data = b"Consistency Test Data 123"
        
        try:
            # Write data
            with open(self.device_path, 'wb') as device:
                device.write(test_data)
            
            # Read it back
            with open(self.device_path, 'rb') as device:
                read_data = device.read(len(test_data))
                
            if read_data == test_data:
                self.test_results["tests"][test_name] = {
                    "status": "PASS",
                    "message": "Write-read consistency verified",
                    "score": 3
                }
                print("  ✅ Read/write consistency: PASS")
                return True
            else:
                self.test_results["tests"][test_name] = {
                    "status": "FAIL",
                    "message": f"Data mismatch: wrote {test_data}, read {read_data}",
                    "score": 0
                }
        except Exception as e:
            self.test_results["tests"][test_name] = {
                "status": "FAIL",
                "message": f"Consistency test failed: {str(e)}",
                "score": 0
            }
        
        print("  ❌ Read/write consistency: FAIL")
        return False
    
    def test_module_unload(self):
        """Test module unloading."""
        test_name = "module_unload"
        print(f"🔧 Testing module unload: {self.module_name}")
        
        returncode, stdout, stderr = self.run_command(f"sudo rmmod {self.module_name}")
        
        if returncode == 0:
            # Verify module is actually unloaded
            if not self.is_module_loaded():
                self.test_results["tests"][test_name] = {
                    "status": "PASS",
                    "message": "Module unloaded successfully",
                    "score": 2
                }
                print("  ✅ Module unload: PASS")
                return True
            else:
                self.test_results["tests"][test_name] = {
                    "status": "FAIL",
                    "message": "Module still loaded after rmmod",
                    "score": 0
                }
        else:
            self.test_results["tests"][test_name] = {
                "status": "FAIL",
                "message": f"rmmod failed: {stderr}",
                "score": 0
            }
        
        print("  ❌ Module unload: FAIL")
        return False
    
    def run_all_tests(self):
        """Run the complete test suite."""
        print(f"🚀 Starting functional tests for {self.module_path}")
        print("=" * 60)
        
        # Test sequence
        tests = [
            self.test_module_load,
            self.test_device_node_creation,
            self.test_device_open_close,
            self.test_device_read,
            self.test_device_write,
            self.test_read_write_consistency,
            self.test_module_unload
        ]
        
        for test_func in tests:
            try:
                test_func()
                self.test_results["summary"]["total_tests"] += 1
            except Exception as e:
                print(f"  ❌ {test_func.__name__}: ERROR - {str(e)}")
                self.test_results["tests"][test_func.__name__] = {
                    "status": "ERROR",
                    "message": str(e),
                    "score": 0
                }
                self.test_results["summary"]["total_tests"] += 1
        
        # Calculate summary
        total_score = 0
        for test_result in self.test_results["tests"].values():
            if test_result["status"] == "PASS":
                self.test_results["summary"]["passed"] += 1
            else:
                self.test_results["summary"]["failed"] += 1
            total_score += test_result["score"]
        
        self.test_results["summary"]["score"] = total_score
        
        # Print summary
        print("\n" + "=" * 60)
        print("📊 FUNCTIONAL TEST SUMMARY")
        print("=" * 60)
        print(f"Total tests: {self.test_results['summary']['total_tests']}")
        print(f"Passed: {self.test_results['summary']['passed']}")
        print(f"Failed: {self.test_results['summary']['failed']}")
        print(f"Total score: {total_score}/17 ({(total_score/17)*100:.1f}%)")
        
        return self.test_results

def main():
    """Main test execution."""
    if len(sys.argv) < 2:
        # Default to hello_world module
        module_path = "src/hello_world.ko"
        device_name = "hello_world"
    else:
        module_path = sys.argv[1]
        device_name = Path(module_path).stem
    
    if not os.path.exists(module_path):
        print(f"❌ Error: Module {module_path} not found")
        print("Please compile the module first with: make")
        sys.exit(1)
    
    # Check if running as root
    if os.geteuid() != 0:
        print("⚠️  Warning: Some tests may fail without root privileges")
        print("Consider running with: sudo python3 tests/test_driver.py")
        print()
    
    # Run tests
    tester = DeviceDriverTester(module_path, device_name)
    results = tester.run_all_tests()
    
    # Save results
    results_file = f"reports/functional_test_results.json"
    os.makedirs("reports", exist_ok=True)
    with open(results_file, 'w') as f:
        json.dump(results, f, indent=2)
    
    print(f"\n📁 Results saved to: {results_file}")
    print("🚀 Ready for report generation!")

if __name__ == "__main__":
    main()
