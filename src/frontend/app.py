"""
Frontend Microservice - Flask Application
==========================================
This is a simple frontend service that provides a web UI for the AKS demo application.
It communicates with the backend API service to fetch and display data.

Author: Atul Kamble
Version: 1.0.0
"""

from flask import Flask, render_template, jsonify, request
import requests
import os
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize Flask application
app = Flask(__name__)

# Configuration from environment variables
BACKEND_API_URL = os.getenv('BACKEND_API_URL', 'http://backend-service:8080')
SERVICE_NAME = os.getenv('SERVICE_NAME', 'frontend')
VERSION = os.getenv('VERSION', '1.0.0')

@app.route('/')
def index():
    """
    Main landing page for the application.
    
    Returns:
        Rendered HTML template with service information
    """
    logger.info("Serving index page")
    return render_template('index.html', 
                         service_name=SERVICE_NAME,
                         version=VERSION)

@app.route('/health')
def health():
    """
    Health check endpoint for Kubernetes liveness and readiness probes.
    
    Returns:
        JSON response with service health status
    """
    health_status = {
        'service': SERVICE_NAME,
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'version': VERSION
    }
    logger.debug("Health check requested")
    return jsonify(health_status), 200

@app.route('/api/data')
def get_data():
    """
    Fetch data from the backend API service.
    
    This endpoint demonstrates inter-service communication within the cluster.
    
    Returns:
        JSON response with data from backend or error message
    """
    try:
        logger.info(f"Fetching data from backend: {BACKEND_API_URL}")
        response = requests.get(f"{BACKEND_API_URL}/api/items", timeout=5)
        response.raise_for_status()
        
        data = response.json()
        logger.info(f"Successfully fetched {len(data.get('items', []))} items")
        return jsonify(data), 200
        
    except requests.exceptions.RequestException as e:
        logger.error(f"Error communicating with backend: {str(e)}")
        return jsonify({
            'error': 'Backend service unavailable',
            'message': str(e)
        }), 503

@app.route('/api/metrics')
def metrics():
    """
    Basic metrics endpoint for monitoring.
    
    Returns:
        JSON response with service metrics
    """
    metrics_data = {
        'service': SERVICE_NAME,
        'version': VERSION,
        'uptime': 'N/A',  # Implement actual uptime tracking
        'requests_total': 'N/A',  # Implement request counter
        'timestamp': datetime.utcnow().isoformat()
    }
    return jsonify(metrics_data), 200

@app.errorhandler(404)
def not_found(error):
    """
    Custom 404 error handler.
    
    Args:
        error: The error object
        
    Returns:
        JSON response with error details
    """
    logger.warning(f"404 error: {request.url}")
    return jsonify({
        'error': 'Not Found',
        'message': 'The requested resource was not found'
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """
    Custom 500 error handler.
    
    Args:
        error: The error object
        
    Returns:
        JSON response with error details
    """
    logger.error(f"500 error: {str(error)}")
    return jsonify({
        'error': 'Internal Server Error',
        'message': 'An unexpected error occurred'
    }), 500

if __name__ == '__main__':
    """
    Main entry point for the application.
    Runs the Flask development server (not recommended for production).
    """
    port = int(os.getenv('PORT', 5000))
    logger.info(f"Starting {SERVICE_NAME} v{VERSION} on port {port}")
    logger.info(f"Backend API URL: {BACKEND_API_URL}")
    
    # For production, use gunicorn or similar WSGI server
    app.run(host='0.0.0.0', port=port, debug=False)
