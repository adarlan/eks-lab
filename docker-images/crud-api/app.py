import re
from flask import request, jsonify

from log_config import logger
from database import create_one_item, read_many_items, update_many_items, delete_many_items, DatabaseException
from flask_config import app, serve

# Creates a new item as long as the name matches the required regex pattern: ^[a-zA-Z]{1,32}+$
@app.route('/api/items', methods=['POST'])
def create_item():

    name = request.json.get('name')

    regex_pattern = r'^[a-zA-Z]{1,32}+$'
    if not bool(re.match(regex_pattern, name)):
        response = {'error': 'Invalid name'}
        logger.info('Received invalid name from client', name=name)
        return jsonify(response), 400

    item = {'name': name}

    try:
        create_one_item(item)
    except DatabaseException as e:
        response = {'error': 'Failed to create item'}
        logger.error('Failed to create item in database', item=item, error=e)
        return jsonify(response), 500

    response = {'message': 'Created item'}
    logger.info('Created item', item=item)
    return jsonify(response), 200

# Fetches all items where the name matches the specified regex pattern
@app.route('/api/items/<regex>', methods=['GET'])
def fetch_items(regex):

    try:
        regex_pattern = re.compile(regex)
    except (re.error, OverflowError, MemoryError) as e:
        response = {'error': 'Invalid regex'}
        logger.info('Received invalid regex from client', regex=regex, error=e, response=response)
        return jsonify(response), 400

    try:
        items = read_many_items(regex_pattern)
    except DatabaseException as e:
        response = {'error': 'Failed to fetch items'}
        logger.error('Failed to read items from database', regex=regex, error=e, response=response)
        return jsonify(response), 500

    fetched_count = len(items)

    message = 'Fetched items' if fetched_count > 0 else 'No items to fetch'
    response = {
        'message': message,
        'regex': regex,
        'fetched_count': fetched_count,
        'items': items
    }
    logger.info(message, regex=regex, fetched_count=fetched_count)
    return jsonify(response), 200

# Updates all items where the name matches the specified regex pattern as long as the specified name matches the required regex pattern: ^[a-zA-Z]{1,32}+$
@app.route('/api/items/<regex>', methods=['PUT'])
def update_item(regex):

    name = request.json.get('name')
    validation_pattern = r'^[a-zA-Z]{1,32}+$'
    if not bool(re.match(validation_pattern, name)):
        response = {'error': 'Invalid name'}
        logger.info('Received invalid name from client', name=name)
        return jsonify(response), 400

    try:
        regex_pattern = re.compile(regex)
    except (re.error, OverflowError, MemoryError) as e:
        response = {'error': 'Invalid regex'}
        logger.info('Received invalid regex from client', regex=regex, error=e, response=response)
        return jsonify(response), 400

    try:
        updated_count = update_many_items(regex_pattern, name)
    except DatabaseException as e:
        response = {'error': 'Failed to update items'}
        logger.error('Failed to update items in database', regex=regex, name=name, error=e, response=response)
        return jsonify(response), 500

    message = 'Updated items' if updated_count > 0 else 'No items to update'
    response = {
        'message': message,
        'regex': regex,
        'name': name,
        'updated_count': updated_count
    }
    logger.info(message, regex=regex, name=name, updated_count=updated_count)
    return jsonify(response), 200

# Deletes all items where the name matches the specified regex pattern
@app.route('/api/items/<regex>', methods=['DELETE'])
def delete_items(regex):

    try:
        regex_pattern = re.compile(regex)
    except (re.error, OverflowError, MemoryError) as e:
        response = {'error': 'Invalid regex'}
        logger.info('Received invalid regex from client', regex=regex, error=e, response=response)
        return jsonify(response), 400

    try:
        deleted_count = delete_many_items(regex_pattern)
    except DatabaseException as e:
        response = {'error': 'Failed to delete items'}
        logger.error('Failed to delete items from database', regex=regex, error=e, response=response)
        return jsonify(response), 500

    message = 'Deleted items' if deleted_count > 0 else 'No items to delete'
    response = {
        'message': message,
        'regex': regex,
        'deleted_count': deleted_count
    }
    logger.info(message, regex=regex, deleted_count=deleted_count)
    return jsonify(response), 200

serve()
