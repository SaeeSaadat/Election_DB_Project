from flask import Flask, request, jsonify
from functools import wraps
import psycopg2
from app import db_conf, app


@app.errorhandler(400)
def bad_request(e):
    return e, 400


def authenticate(function):
    @wraps(function)
    def wrapper(*args, **kwargs):
        req = request.get_json()
        if 'user' in req and 'password' in req:
            conf = db_conf()
            conf['user'] = req['user']
            conf['password'] = req['password']
            connection = psycopg2.connect(**conf)
            return function(user=req['user'], connection=connection, *args, **kwargs)
        else:
            return bad_request('username or password was not provided!')

    return wrapper
