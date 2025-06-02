#!/usr/bin/env python3
"""
Debug version of the Starbase1 System Monitor Flask Application
Adds extensive logging to help diagnose Windows container issues
"""

from flask import Flask, render_template, jsonify
import os
import sys
import traceback
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Add collectors to path
sys.path.append(os.path.dirname(__file__))

from config import config
from collectors.security_collector import SecurityCollector
from collectors.service_collector import ServiceCollector
from collectors.system_collector import SystemCollector

def create_app(config_name=None):
    """Create Flask application with debug logging"""
    app = Flask(__name__)
    
    # Load configuration
    config_name = config_name or os.environ.get('FLASK_CONFIG') or 'default'
    app.config.from_object(config[config_name])
    
    logger.info(f"Starting app with config: {config_name}")
    logger.info(f"Environment variables: CONTAINER_MODE={os.environ.get('CONTAINER_MODE')}, "
                f"DISABLE_HARDWARE_MONITORING={os.environ.get('DISABLE_HARDWARE_MONITORING')}, "
                f"DISABLE_TEMPERATURE_MONITORING={os.environ.get('DISABLE_TEMPERATURE_MONITORING')}")
    
    # Initialize collectors with error handling
    try:
        security_collector = SecurityCollector()
        logger.info("Security collector initialized")
    except Exception as e:
        logger.error(f"Failed to initialize security collector: {e}")
        security_collector = None
        
    try:
        service_collector = ServiceCollector(app.config['MONITORED_SERVICES'])
        logger.info("Service collector initialized")
    except Exception as e:
        logger.error(f"Failed to initialize service collector: {e}")
        service_collector = None
        
    try:
        system_collector = SystemCollector()
        logger.info("System collector initialized")
    except Exception as e:
        logger.error(f"Failed to initialize system collector: {e}")
        system_collector = None
    
    @app.route('/')
    def index():
        """Main dashboard view"""
        return render_template('dashboard.html',
                             app_name='Starbase1 System Monitor',
                             refresh_interval=6000)
    
    @app.route('/api/security')
    def api_security():
        """API endpoint for security data"""
        try:
            if not security_collector:
                return jsonify({'error': 'Security collector not initialized', 'data': {}}), 200
                
            data = security_collector.get_security_summary()
            logger.debug(f"Security data: {data}")
            return jsonify(data)
        except Exception as e:
            logger.error(f"Security API error: {traceback.format_exc()}")
            return jsonify({'error': str(e), 'data': {}}), 200
    
    @app.route('/api/services')
    def api_services():
        """API endpoint for service data"""
        try:
            if not service_collector:
                return jsonify({'error': 'Service collector not initialized', 'data': {}}), 200
                
            data = service_collector.get_service_summary()
            logger.debug(f"Service data: {data}")
            return jsonify(data)
        except Exception as e:
            logger.error(f"Services API error: {traceback.format_exc()}")
            return jsonify({'error': str(e), 'data': {}}), 200
    
    @app.route('/api/system')
    def api_system():
        """API endpoint for system data"""
        try:
            if not system_collector:
                return jsonify({'error': 'System collector not initialized', 'data': {}}), 200
                
            data = system_collector.get_system_summary()
            logger.debug(f"System data: {data}")
            return jsonify(data)
        except Exception as e:
            logger.error(f"System API error: {traceback.format_exc()}")
            return jsonify({'error': str(e), 'data': {}}), 200
    
    @app.route('/api/status')
    def api_status():
        """Combined status API endpoint"""
        try:
            result = {
                'timestamp': datetime.now().isoformat(),
                'security': {},
                'services': {},
                'system': {},
                'overall_status': 'unknown',
                'errors': []
            }
            
            # Collect data with individual error handling
            if security_collector:
                try:
                    result['security'] = security_collector.get_security_summary()
                except Exception as e:
                    result['errors'].append(f"Security: {str(e)}")
                    logger.error(f"Security collection error: {traceback.format_exc()}")
                    
            if service_collector:
                try:
                    result['services'] = service_collector.get_service_summary()
                except Exception as e:
                    result['errors'].append(f"Services: {str(e)}")
                    logger.error(f"Service collection error: {traceback.format_exc()}")
                    
            if system_collector:
                try:
                    result['system'] = system_collector.get_system_summary()
                except Exception as e:
                    result['errors'].append(f"System: {str(e)}")
                    logger.error(f"System collection error: {traceback.format_exc()}")
            
            # Determine overall status
            if result['errors']:
                result['overall_status'] = 'error'
            else:
                result['overall_status'] = 'good'
            
            return jsonify(result)
        except Exception as e:
            logger.error(f"Status API error: {traceback.format_exc()}")
            return jsonify({'error': str(e), 'timestamp': datetime.now().isoformat()}), 200
    
    @app.route('/health')
    def health_check():
        """Health check endpoint"""
        return jsonify({
            'status': 'healthy',
            'app': app.config['APP_NAME'],
            'version': app.config['APP_VERSION'],
            'timestamp': datetime.now().isoformat(),
            'collectors': {
                'security': 'initialized' if security_collector else 'failed',
                'service': 'initialized' if service_collector else 'failed',
                'system': 'initialized' if system_collector else 'failed'
            }
        })
    
    @app.route('/debug')
    def debug_info():
        """Debug endpoint to check environment"""
        return jsonify({
            'environment': dict(os.environ),
            'platform': sys.platform,
            'python_version': sys.version,
            'working_directory': os.getcwd(),
            'collectors_status': {
                'security': 'initialized' if security_collector else 'failed',
                'service': 'initialized' if service_collector else 'failed',
                'system': 'initialized' if system_collector else 'failed'
            }
        })
    
    return app

# Create Flask app
app = create_app()

if __name__ == '__main__':
    import sys
    import os
    
    # Check if we're in container mode
    container_mode = os.environ.get('CONTAINER_MODE', 'false').lower() == 'true'
    
    # Determine host and port
    if container_mode:
        # In container, listen on all interfaces
        host = '0.0.0.0'
        port = int(os.environ.get('PORT', 8080))
        debug = False
    else:
        # Local development
        host = '127.0.0.1'
        port = int(os.environ.get('PORT', 8080))
        debug = True
    
    logger.info(f"Starting Flask app on {host}:{port} (container_mode={container_mode})")
    
    # Run the app
    app.run(host=host, port=port, debug=debug)