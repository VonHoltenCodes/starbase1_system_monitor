#!/usr/bin/env python3
"""
Minimal version of Starbase1 System Monitor
Returns static data to test if the issue is with collectors
"""

from flask import Flask, render_template, jsonify
from datetime import datetime
import os

app = Flask(__name__)

@app.route('/')
def index():
    """Main dashboard view"""
    return render_template('dashboard.html')

@app.route('/api/system')
def api_system():
    """Return static system data in the format dashboard.js expects"""
    return jsonify({
        'cpu': {
            'model': 'Test CPU (Container Mode)',
            'usage': 25.5,  # Changed from usage_percent
            'physical_cores': 4,
            'logical_cores': 8,
            'frequency': 2400.0
        },
        'memory': {
            'total': 17179869184,  # 16GB in bytes
            'used': 8589934592,    # 8GB in bytes
            'percent': 50.0
        },
        'disks': [
            {
                'device': 'C:\\',
                'total': 536870912000,  # 500GB in bytes
                'used': 268435456000,   # 250GB in bytes
                'free': 268435456000,   # 250GB in bytes
                'percent': 50.0
            }
        ],
        'network': {
            'interfaces': [{'name': 'eth0', 'status': 'up', 'ip': '172.17.0.2'}]
        },
        'temperatures': [],  # Empty array as expected by JS
        'bios': {
            'vendor': 'Container BIOS',
            'version': '1.0',
            'motherboard': 'Docker Virtual'
        },
        'uptime': '1 day, 2:30:00'
    })

@app.route('/api/security')
def api_security():
    """Return static security data"""
    return jsonify({
        'active_users': [
            {'username': 'container_user', 'terminal': 'docker', 'status': 'active'}
        ],
        'failed_logins': {
            'total': 0,
            'attempts': [],
            'summary': {'status': 'ok', 'message': 'No failed logins'}
        },
        'overall_status': 'good'
    })

@app.route('/api/services')
def api_services():
    """Return static service data"""
    return jsonify({
        'services': [
            {'name': 'docker', 'status': 'active', 'active': True},
            {'name': 'flask', 'status': 'active', 'active': True}
        ],
        'summary': {
            'total': 2,
            'active': 2,
            'inactive': 0,
            'overall_status': 'good'
        }
    })

@app.route('/api/status')
def api_status():
    """Return combined status"""
    return jsonify({
        'timestamp': datetime.now().isoformat(),
        'overall_status': 'good',
        'message': 'Minimal test mode - static data'
    })

@app.route('/health')
def health():
    """Health check"""
    return jsonify({
        'status': 'healthy',
        'mode': 'minimal',
        'timestamp': datetime.now().isoformat()
    })

if __name__ == '__main__':
    # Always run on all interfaces in container
    app.run(host='0.0.0.0', port=8080, debug=False)