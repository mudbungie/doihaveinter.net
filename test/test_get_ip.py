import io
import json
import sys
import os
import unittest

# Add src directory to path to import get_ip module
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'src'))

from get_ip import get_caller_ip, handler


class TestGetIP(unittest.TestCase):
    
    def test_get_caller_ip_with_valid_payload(self):
        """Test extracting IP from a valid OCI API Gateway payload"""
        payload = {
            "requestContext": {
                "identity": {
                    "sourceIp": "203.0.113.42"
                }
            }
        }
        result = get_caller_ip(payload)
        self.assertEqual(result, {"ip": "203.0.113.42"})

    def test_get_caller_ip_with_json_string(self):
        """Test with JSON string input"""
        payload = json.dumps({
            "requestContext": {
                "identity": {
                    "sourceIp": "198.51.100.1"
                }
            }
        })
        result = get_caller_ip(payload)
        self.assertEqual(result, {"ip": "198.51.100.1"})

    def test_get_caller_ip_with_bytes(self):
        """Test with bytes input"""
        payload = json.dumps({
            "requestContext": {
                "identity": {
                    "sourceIp": "192.0.2.100"
                }
            }
        }).encode('utf-8')
        result = get_caller_ip(payload)
        self.assertEqual(result, {"ip": "192.0.2.100"})

    def test_get_caller_ip_with_bytesio(self):
        """Test with BytesIO input (as used by OCI Functions)"""
        payload_dict = {
            "requestContext": {
                "identity": {
                    "sourceIp": "10.0.0.50"
                }
            }
        }
        payload = io.BytesIO(json.dumps(payload_dict).encode('utf-8'))
        result = get_caller_ip(payload)
        self.assertEqual(result, {"ip": "10.0.0.50"})

    def test_get_caller_ip_missing_ip(self):
        """Test with missing IP address in payload"""
        payload = {
            "requestContext": {
                "identity": {}
            }
        }
        result = get_caller_ip(payload)
        self.assertIn("error", result)
        self.assertIn("not found", result["error"].lower())

    def test_get_caller_ip_missing_context(self):
        """Test with missing requestContext"""
        payload = {}
        result = get_caller_ip(payload)
        self.assertIn("error", result)

    def test_get_caller_ip_invalid_json(self):
        """Test with invalid JSON"""
        payload = "{invalid json"
        result = get_caller_ip(payload)
        self.assertIn("error", result)
        self.assertIn("json", result["error"].lower())

    def test_handler_function(self):
        """Test the OCI Function handler"""
        payload_dict = {
            "requestContext": {
                "identity": {
                    "sourceIp": "172.16.0.1"
                }
            }
        }
        payload = io.BytesIO(json.dumps(payload_dict).encode('utf-8'))
        result = handler(None, payload)
        self.assertEqual(result, {"ip": "172.16.0.1"})


if __name__ == "__main__":
    unittest.main()
