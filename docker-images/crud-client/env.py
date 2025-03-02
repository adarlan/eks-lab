import os
import logging

APP_ENVIRONMENT = os.environ.get('APP_ENVIRONMENT', 'development')
LOG_LEVEL = logging._nameToLevel[os.environ.get('LOG_LEVEL', 'DEBUG')]

API_URL = os.environ.get('API_URL', 'http://localhost:8011/api/items')

MIN_ITERATIONS = int(os.environ.get('MIN_ITERATIONS', '1'))
MAX_ITERATIONS = int(os.environ.get('MAX_ITERATIONS', '10'))

INVALID_INPUT_CHANCE = float(os.environ.get('INVALID_INPUT_CHANCE', '0.1'))

POST_WEIGHT   = float(os.environ.get('POST_WEIGHT', '0.25'))
GET_WEIGHT    = float(os.environ.get('GET_WEIGHT', '0.25'))
PUT_WEIGHT    = float(os.environ.get('PUT_WEIGHT', '0.25'))
DELETE_WEIGHT = float(os.environ.get('DELETE_WEIGHT', '0.25'))
