import random
import string
import os
from urllib.parse import quote

from env import MIN_ITERATIONS, MAX_ITERATIONS, INVALID_INPUT_CHANCE, POST_WEIGHT, GET_WEIGHT, PUT_WEIGHT, DELETE_WEIGHT

def random_iteration_count():
    return random.randint(MIN_ITERATIONS, MAX_ITERATIONS)

def random_method():
    methods = ["post", "get", "put", "delete"]
    weights = [POST_WEIGHT, GET_WEIGHT, PUT_WEIGHT, DELETE_WEIGHT]
    return random.choices(methods, weights=weights, k=1)[0]

def random_name_length():
    if random.uniform(0, 1) < INVALID_INPUT_CHANCE:
        return random.randint(33, 64)
    else:
        return random.randint(1, 32)

def random_name():
    length = random_name_length()
    name = ''.join(random.choice(string.ascii_letters) for _ in range(length))
    return name

def random_regex():
    length = random_name_length()
    regex = '^[a-zA-Z]{' + str(length) + '}$'
    return regex

def encoded_regex(regex):
    return quote(regex)
