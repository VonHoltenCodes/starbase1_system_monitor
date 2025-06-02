#!/usr/bin/env python3
"""
Fixed minimal version of Starbase1 System Monitor
Returns data in exact format expected by dashboard.js
"""

from flask import Flask, render_template, jsonify
from datetime import datetime
import os

app = Flask(__name__)

@app.route('/')
def index():
    """Main dashboard view"""
    return render_template('dashboard.html', 
                         app_name='Starbase1 System Monitor',
                         refresh_interval=6000)

@app.route('/debug')
def debug():
    """Debug test page"""
    try:
        with open('debug_test.html', 'r') as f:
            return f.read()
    except:
        return "Debug test file not found", 404

@app.route('/api/system')
def api_system():
    """Return static system data matching dashboard.js expectations"""
    return jsonify({
        'cpu': {
            'model': 'Intel Core i7-9700K @ 3.60GHz',
            'usage': 15.2,  # dashboard.js expects 'usage' not 'usage_percent'
            'physical_cores': 8,
            'logical_cores': 8,
            'frequency': 3600.0  # MHz
        },
        'memory': {
            'total': 17179869184,  # 16GB in bytes
            'used': 6442450944,    # 6GB in bytes
            'available': 10737418240,  # 10GB in bytes
            'percent': 37.5
        },
        'disks': [
            {
                'device': 'C:\\',
                'mountpoint': 'C:\\',
                'total': 536870912000,  # 500GB in bytes
                'used': 214748364800,   # 200GB in bytes
                'free': 322122547200,   # 300GB in bytes
                'percent': 40.0
            }
        ],
        'network': {
            'interfaces': [
                {'name': 'Ethernet', 'status': 'up', 'ip': '192.168.1.100'},
                {'name': 'WiFi', 'status': 'up', 'ip': '192.168.1.101'}
            ],
            'bytes_sent': 1073741824,  # 1GB
            'bytes_recv': 2147483648   # 2GB
        },
        'temperatures': [
            {
                'label': 'CPU Core',
                'current': 45.0,
                'high': 80.0,
                'critical': 100.0
            }
        ],
        'bios': {
            'vendor': 'American Megatrends Inc.',
            'version': 'F5',
            'motherboard': 'Z390 AORUS PRO'
        },
        'uptime': 224400  # 2.6 days in seconds
    })

@app.route('/api/security')
def api_security():
    """Return static security data matching dashboard.js expectations"""
    return jsonify({
        'active_users': [
            {
                'name': 'Administrator',  # dashboard.js expects 'name' not 'username'
                'terminal': 'Console',
                'started': '2024-01-06 09:00',
                'status': 'active'
            },
            {
                'name': 'docker_user',
                'terminal': 'Remote',
                'started': '2024-01-06 10:30',
                'status': 'active'
            }
        ],
        'failed_logins': 3,  # dashboard.js expects a number, not an object
        'last_failure': '2024-01-06 08:45:00',
        'overall_status': 'good'
    })

@app.route('/api/services')
def api_services():
    """Return static service data matching dashboard.js expectations"""
    return jsonify({
        'services': [
            {
                'name': 'Docker Desktop',
                'status': 'active',  # dashboard.js checks if status === 'active'
                'active': True,
                'description': 'Docker Desktop Service'
            },
            {
                'name': 'Windows Defender',
                'status': 'active',
                'active': True,
                'description': 'Windows Defender Antivirus Service'
            },
            {
                'name': 'Windows Update',
                'status': 'inactive',
                'active': False,
                'description': 'Windows Update Service'
            }
        ],
        'summary': {
            'total': 3,
            'active': 2,
            'inactive': 1,
            'overall_status': 'good'
        }
    })

@app.route('/api/status')
def api_status():
    """Return combined status"""
    return jsonify({
        'timestamp': datetime.now().isoformat(),
        'overall_status': 'good',
        'system': {'status': 'operational'},
        'security': {'status': 'secure'},
        'services': {'status': 'healthy'}
    })

@app.route('/health')
def health():
    """Health check"""
    return jsonify({
        'status': 'healthy',
        'app': 'Starbase1 System Monitor',
        'version': '1.0.0',
        'timestamp': datetime.now().isoformat()
    })

if __name__ == '__main__':
    # Always run on all interfaces in container
    app.run(host='0.0.0.0', port=8080, debug=False)