import sys
import os
import unittest

# Add src directory to path to import get_ip module
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'src'))

from get_ip import app


class TestGetIP(unittest.TestCase):
    
    def setUp(self):
        """Set up test client."""
        self.app = app.test_client()
        self.app.testing = True

    def test_get_ip_endpoint(self):
        """Test the /ip endpoint returns an IP."""
        response = self.app.get('/ip')
        self.assertEqual(response.status_code, 200)
        data = response.text
        self.assertIn('.', data)

    def test_ip_with_endline_endpoint(self):
        """Test the /ip endpoint returns an IP with endline."""
        response = self.app.get('/IP')
        self.assertEqual(response.status_code, 200)
        data = response.text
        self.assertTrue(data.endswith('\n'))

    def test_get_ip_json_endpoint(self):
        """Test the /ip endpoint returns an IP."""
        response = self.app.get('/ip.json')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertIn('ip', data)
        self.assertIsNotNone(data['ip'])

    def test_get_ip_with_forwarded_header(self):
        """Test IP extraction from X-Forwarded-For header."""
        response = self.app.get('/ip.json', headers={'X-Forwarded-For': '203.0.113.42'})
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertEqual(data['ip'], '203.0.113.42')

    def test_get_ip_with_multiple_forwarded_ips(self):
        """Test IP extraction from X-Forwarded-For with multiple IPs."""
        response = self.app.get('/ip.json', headers={'X-Forwarded-For': '198.51.100.1, 192.0.2.100'})
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertEqual(data['ip'], '198.51.100.1')

    def test_get_ip_with_real_ip_header(self):
        """Test IP extraction from X-Real-IP header."""
        response = self.app.get('/ip.json', headers={'X-Real-IP': '10.0.0.50'})
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertEqual(data['ip'], '10.0.0.50')

    def test_get_ip_post_method(self):
        """Test /ip endpoint with POST method."""
        response = self.app.post('/ip.json')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertIn('ip', data)

    def test_health_endpoint(self):
        """Test the /health endpoint."""
        response = self.app.get('/health')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertEqual(data['status'], 'ok')

    def test_root_endpoint(self):
        """Test the root endpoint."""
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)
        data = response.text
        self.assertIn("Internet", data)


if __name__ == "__main__":
    unittest.main()
