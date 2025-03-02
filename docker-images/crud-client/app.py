import requests
import utils
from log_config import logger
from env import API_URL

# Create item generating a random name
def post():
    url = API_URL
    data = {'name': utils.random_name()}

    response = requests.post(url, json=data)
    try:
        response.raise_for_status()
        logger.info('Request to create item succeeded',
            url=url,
            data=data,
            response_status=response.status_code,
            response_data=response.json())

    except requests.exceptions.RequestException as e:
        logger.error('Request to create item failed',
            url=url,
            data=data,
            response_status=response.status_code,
            error=e)

# Fetch items with a random filter
def get():
    regex = utils.random_regex()
    url = API_URL + '/' + utils.encoded_regex(regex)

    response = requests.get(url)
    try:
        response.raise_for_status()
        logger.info('Request to fetch items succeeded',
            regex=regex,
            url=url,
            response_status=response.status_code,
            response_data=response.json())
        # TODO do not log the entire response

    except requests.exceptions.RequestException as e:
        logger.error('Request to fetch items failed',
            regex=regex,
            url=url,
            response_status=response.status_code,
            error=e)

# Update items with a random filter and generating a random name
def put():
    regex = utils.random_regex()
    url = API_URL + '/' + utils.encoded_regex(regex)
    data = {'name': utils.random_name()}

    response = requests.put(url, json=data)
    try:
        response.raise_for_status()
        logger.info('Request to update items succeeded',
            regex=regex,
            url=url,
            data=data,
            response_status=response.status_code,
            response_data=response.json())

    except requests.exceptions.RequestException as e:
        logger.error('Request to update items failed',
            regex=regex,
            url=url,
            data=data,
            response_status=response.status_code,
            error=e)

# Delete items using a random filter
def delete():
    regex = utils.random_regex()
    url = API_URL + '/' + utils.encoded_regex(regex)

    response = requests.delete(url)
    try:
        response.raise_for_status()
        logger.info('Request to delete items succeeded',
            regex=regex,
            url=url,
            response_status=response.status_code,
            response_data=response.json())

    except requests.exceptions.RequestException as e:
        logger.error('Request to delete items failed',
            regex=regex,
            url=url,
            response_status=response.status_code,
            error=e)

# Do a random number of iterations, executing a random method for each iteration
iteration_count = utils.random_iteration_count()
for i in range(0, iteration_count):
    method = utils.random_method()
    if method == "post":
        post()
    if method == "get":
        get()
    if method == "put":
        put()
    if method == "delete":
        delete()
