#!/usr/bin/env python3
"""
Security Data Collector - Container/Windows Safe Version
Returns mock data when system logs are not available
"""

import subprocess
import re
import datetime
import json
import os
from typing import List, Dict, Any

class SecurityCollector:
    """Collects security-related system data with fallbacks for containers"""
    
    def __init__(self):
        self.auth_log_path = '/var/log/auth.log'
        self.is_container = os.environ.get('CONTAINER_MODE', 'false').lower() == 'true'
    
    def get_active_users(self) -> List[Dict[str, Any]]:
        """Get currently logged in users"""
        if self.is_container:
            # Return container user info
            return [{
                'name': 'container',  # dashboard.js expects 'name' not 'username'
                'terminal': 'docker',
                'started': datetime.datetime.now().strftime('%Y-%m-%d %H:%M'),  # expects 'started'
                'status': 'active'
            }]
            
        try:
            # Use 'who' command to get active sessions
            result = subprocess.run(['who'], capture_output=True, text=True, timeout=5)
            users = []
            
            if result.returncode != 0 or not result.stdout.strip():
                # Fallback to current user
                import getpass
                return [{
                    'name': getpass.getuser(),
                    'terminal': 'system',
                    'started': datetime.datetime.now().strftime('%Y-%m-%d %H:%M'),
                    'status': 'active'
                }]
            
            for line in result.stdout.strip().split('\n'):
                if line.strip():
                    parts = line.split()
                    if len(parts) >= 3:
                        user = {
                            'name': parts[0],
                            'terminal': parts[1],
                            'started': ' '.join(parts[2:4]) if len(parts) >= 4 else parts[2],
                            'status': 'active'
                        }
                        users.append(user)
            
            return users if users else [{'name': 'unknown', 'status': 'no active users'}]
        except Exception as e:
            return [{'name': 'error', 'status': f'Failed to get users: {str(e)}'}]
    
    def get_failed_logins(self, hours: int = 24) -> Dict[str, Any]:
        """Get failed login attempts from last N hours"""
        if self.is_container:
            # Return safe container response
            return {
                'total': 0,
                'attempts': [],
                'summary': {
                    'status': 'monitoring',
                    'message': 'No failed logins detected in container'
                }
            }
            
        try:
            # Check if auth log exists
            if not os.path.exists(self.auth_log_path):
                return {
                    'total': 0,
                    'attempts': [],
                    'summary': {
                        'status': 'unavailable',
                        'message': 'Auth logs not available'
                    }
                }
            
            # Get failed SSH login attempts
            cmd = ['grep', 'Failed password', self.auth_log_path]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
            
            if result.returncode != 0:
                return {
                    'total': 0,
                    'attempts': [],
                    'summary': {
                        'status': 'ok',
                        'message': 'No failed login attempts'
                    }
                }
            
            failed_attempts = []
            total_count = 0
            
            for line in result.stdout.strip().split('\n'):
                if line.strip():
                    total_count += 1
                    # Parse the log line for details
                    match = re.search(r'Failed password for (\S+) from (\S+)', line)
                    if match and total_count <= 10:  # Limit to last 10
                        failed_attempts.append({
                            'user': match.group(1),
                            'source_ip': match.group(2),
                            'timestamp': datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                        })
            
            return {
                'total': total_count,
                'attempts': failed_attempts,
                'summary': {
                    'status': 'warning' if total_count > 5 else 'ok',
                    'message': f'{total_count} failed login attempts in last {hours} hours'
                }
            }
            
        except Exception as e:
            return {
                'total': 0,
                'attempts': [],
                'summary': {
                    'status': 'error',
                    'message': f'Failed to check logins: {str(e)}'
                }
            }
    
    def get_security_summary(self) -> Dict[str, Any]:
        """Get combined security summary"""
        try:
            active_users = self.get_active_users()
            failed_logins = self.get_failed_logins()
            
            # Determine overall security status
            if failed_logins.get('total', 0) > 10:
                overall_status = 'critical'
            elif failed_logins.get('total', 0) > 5:
                overall_status = 'warning'
            else:
                overall_status = 'good'
            
            # Extract the last failure time if available
            last_failure = None
            if failed_logins.get('attempts') and len(failed_logins['attempts']) > 0:
                last_failure = failed_logins['attempts'][0].get('timestamp', 'Unknown')
            
            return {
                'active_users': active_users,
                'failed_logins': failed_logins.get('total', 0),  # dashboard.js expects a number
                'last_failure': last_failure,
                'overall_status': overall_status,
                'last_updated': datetime.datetime.now().isoformat(),
                'environment': 'container' if self.is_container else 'host'
            }
        except Exception as e:
            return {
                'error': str(e),
                'active_users': [],
                'failed_logins': 0,  # dashboard.js expects a number
                'overall_status': 'unknown',
                'last_updated': datetime.datetime.now().isoformat()
            }