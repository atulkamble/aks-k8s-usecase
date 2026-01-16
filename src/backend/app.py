"""
Backend API Microservice - Flask REST API
==========================================
This is the backend API service that provides RESTful endpoints for the application.
It includes CRUD operations, database connectivity, and authentication handling.

Author: Atul Kamble
Version: 1.0.0
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
import os
import logging
from datetime import datetime
import uuid

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize Flask application
app = Flask(__name__)
CORS(app)  # Enable CORS for frontend communication

# Configuration from environment variables
SERVICE_NAME = os.getenv('SERVICE_NAME', 'backend')
VERSION = os.getenv('VERSION', '1.0.0')
DATABASE_URL = os.getenv('DATABASE_URL', 'sqlite:///app.db')

# In-memory data store (replace with actual database in production)
items_store = {
    '1': {'id': '1', 'name': 'Sample Item 1', 'description': 'First demo item', 'created_at': datetime.utcnow().isoformat()},
    '2': {'id': '2', 'name': 'Sample Item 2', 'description': 'Second demo item', 'created_at': datetime.utcnow().isoformat()},
    '3': {'id': '3', 'name': 'Sample Item 3', 'description': 'Third demo item', 'created_at': datetime.utcnow().isoformat()}
}

@app.route('/')
def index():
    """
    Root endpoint with API information.
    
    Returns:
        JSON response with API details
    """
    logger.info("Root endpoint accessed")
    return jsonify({
        'service': SERVICE_NAME,
        'version': VERSION,
        'status': 'running',
        'endpoints': {
            'health': '/health',
            'items': '/api/items',
            'item': '/api/items/<id>'
        }
    }), 200

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
        'version': VERSION,
        'database': 'connected'  # Add actual DB health check
    }
    logger.debug("Health check requested")
    return jsonify(health_status), 200

@app.route('/ready')
def ready():
    """
    Readiness probe endpoint.
    Checks if the service is ready to accept traffic.
    
    Returns:
        JSON response with readiness status
    """
    # Add actual readiness checks (DB connection, dependencies, etc.)
    return jsonify({
        'service': SERVICE_NAME,
        'ready': True,
        'timestamp': datetime.utcnow().isoformat()
    }), 200

@app.route('/api/items', methods=['GET'])
def get_items():
    """
    Retrieve all items.
    
    Query Parameters:
        limit (int): Maximum number of items to return
        offset (int): Number of items to skip
    
    Returns:
        JSON response with list of items
    """
    try:
        limit = request.args.get('limit', default=100, type=int)
        offset = request.args.get('offset', default=0, type=int)
        
        logger.info(f"Fetching items (limit={limit}, offset={offset})")
        
        items_list = list(items_store.values())[offset:offset+limit]
        
        return jsonify({
            'items': items_list,
            'total': len(items_store),
            'limit': limit,
            'offset': offset
        }), 200
        
    except Exception as e:
        logger.error(f"Error fetching items: {str(e)}")
        return jsonify({'error': 'Failed to fetch items', 'message': str(e)}), 500

@app.route('/api/items/<item_id>', methods=['GET'])
def get_item(item_id):
    """
    Retrieve a specific item by ID.
    
    Args:
        item_id (str): The unique identifier of the item
    
    Returns:
        JSON response with item details or error
    """
    logger.info(f"Fetching item with ID: {item_id}")
    
    item = items_store.get(item_id)
    if item:
        return jsonify(item), 200
    else:
        logger.warning(f"Item not found: {item_id}")
        return jsonify({'error': 'Item not found', 'id': item_id}), 404

@app.route('/api/items', methods=['POST'])
def create_item():
    """
    Create a new item.
    
    Request Body:
        name (str): Item name
        description (str): Item description
    
    Returns:
        JSON response with created item
    """
    try:
        data = request.get_json()
        
        if not data or 'name' not in data:
            return jsonify({'error': 'Name is required'}), 400
        
        item_id = str(uuid.uuid4())
        new_item = {
            'id': item_id,
            'name': data['name'],
            'description': data.get('description', ''),
            'created_at': datetime.utcnow().isoformat()
        }
        
        items_store[item_id] = new_item
        logger.info(f"Created new item: {item_id}")
        
        return jsonify(new_item), 201
        
    except Exception as e:
        logger.error(f"Error creating item: {str(e)}")
        return jsonify({'error': 'Failed to create item', 'message': str(e)}), 500

@app.route('/api/items/<item_id>', methods=['PUT'])
def update_item(item_id):
    """
    Update an existing item.
    
    Args:
        item_id (str): The unique identifier of the item
    
    Request Body:
        name (str): Updated item name
        description (str): Updated item description
    
    Returns:
        JSON response with updated item
    """
    try:
        if item_id not in items_store:
            return jsonify({'error': 'Item not found', 'id': item_id}), 404
        
        data = request.get_json()
        item = items_store[item_id]
        
        item['name'] = data.get('name', item['name'])
        item['description'] = data.get('description', item['description'])
        item['updated_at'] = datetime.utcnow().isoformat()
        
        logger.info(f"Updated item: {item_id}")
        return jsonify(item), 200
        
    except Exception as e:
        logger.error(f"Error updating item: {str(e)}")
        return jsonify({'error': 'Failed to update item', 'message': str(e)}), 500

@app.route('/api/items/<item_id>', methods=['DELETE'])
def delete_item(item_id):
    """
    Delete an item.
    
    Args:
        item_id (str): The unique identifier of the item
    
    Returns:
        JSON response confirming deletion
    """
    try:
        if item_id not in items_store:
            return jsonify({'error': 'Item not found', 'id': item_id}), 404
        
        del items_store[item_id]
        logger.info(f"Deleted item: {item_id}")
        
        return jsonify({'message': 'Item deleted successfully', 'id': item_id}), 200
        
    except Exception as e:
        logger.error(f"Error deleting item: {str(e)}")
        return jsonify({'error': 'Failed to delete item', 'message': str(e)}), 500

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
        'items_count': len(items_store),
        'uptime': 'N/A',  # Implement actual uptime tracking
        'requests_total': 'N/A',  # Implement request counter
        'timestamp': datetime.utcnow().isoformat()
    }
    return jsonify(metrics_data), 200

@app.errorhandler(404)
def not_found(error):
    """Custom 404 error handler."""
    logger.warning(f"404 error: {request.url}")
    return jsonify({'error': 'Not Found', 'message': 'The requested resource was not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    """Custom 500 error handler."""
    logger.error(f"500 error: {str(error)}")
    return jsonify({'error': 'Internal Server Error', 'message': 'An unexpected error occurred'}), 500

if __name__ == '__main__':
    """
    Main entry point for the application.
    """
    port = int(os.getenv('PORT', 8080))
    logger.info(f"Starting {SERVICE_NAME} v{VERSION} on port {port}")
    logger.info(f"Database URL: {DATABASE_URL}")
    
    # For production, use gunicorn or similar WSGI server
    app.run(host='0.0.0.0', port=port, debug=False)
