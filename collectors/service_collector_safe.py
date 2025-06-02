#!/usr/bin/env python3
"""
Service Collector - Container/Windows Safe Version
Provides service status with container-aware fallbacks
"""

import subprocess
import os
from typing import List, Dict, Any
from datetime import datetime

class ServiceCollector:
    """Collects service status data with container support"""
    
    def __init__(self, monitored_services: List[str]):
        self.monitored_services = monitored_services
        self.is_container = os.environ.get('CONTAINER_MODE', 'false').lower() == 'true'
    
    def check_service_status(self, service_name: str) -> Dict[str, Any]:
        """Check status of a single service"""
        if self.is_container:
            # In container, return mock status
            return {
                'name': service_name,
                'status': 'container-mode',
                'active': True,
                'description': f'{service_name} (container environment)',
                'message': 'Service monitoring not available in container'
            }
        
        try:
            # Try systemctl first (most Linux systems)
            cmd = ['systemctl', 'is-active', service_name]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
            
            if result.returncode == 0:
                status = result.stdout.strip()
                return {
                    'name': service_name,
                    'status': status,
                    'active': status == 'active',
                    'description': f'{service_name} service'
                }
            else:
                # Service not found or not active
                return {
                    'name': service_name,
                    'status': 'inactive',
                    'active': False,
                    'description': f'{service_name} service'
                }
                
        except FileNotFoundError:
            # systemctl not available (could be container or non-systemd system)
            return {
                'name': service_name,
                'status': 'unknown',
                'active': None,
                'description': f'{service_name} service',
                'message': 'Service monitoring not available'
            }
        except Exception as e:
            return {
                'name': service_name,
                'status': 'error',
                'active': False,
                'description': f'{service_name} service',
                'error': str(e)
            }
    
    def get_service_summary(self) -> Dict[str, Any]:
        """Get summary of all monitored services"""
        try:
            services = []
            active_count = 0
            inactive_count = 0
            unknown_count = 0
            
            for service_name in self.monitored_services:
                service_info = self.check_service_status(service_name)
                services.append(service_info)
                
                if service_info.get('active') is True:
                    active_count += 1
                elif service_info.get('active') is False:
                    inactive_count += 1
                else:
                    unknown_count += 1
            
            # Determine overall status
            if inactive_count > len(self.monitored_services) // 2:
                overall_status = 'critical'
            elif inactive_count > 0:
                overall_status = 'warning'
            elif unknown_count == len(self.monitored_services):
                overall_status = 'unknown'
            else:
                overall_status = 'good'
            
            return {
                'services': services,
                'summary': {
                    'total': len(self.monitored_services),
                    'active': active_count,
                    'inactive': inactive_count,
                    'unknown': unknown_count,
                    'overall_status': overall_status
                },
                'last_updated': datetime.now().isoformat(),
                'environment': 'container' if self.is_container else 'host'
            }
            
        except Exception as e:
            return {
                'error': str(e),
                'services': [],
                'summary': {
                    'total': 0,
                    'active': 0,
                    'inactive': 0,
                    'unknown': 0,
                    'overall_status': 'error'
                },
                'last_updated': datetime.now().isoformat()
            }