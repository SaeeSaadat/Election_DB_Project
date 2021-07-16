from flask import Flask, request, jsonify
from functools import wraps
import psycopg2
import psycopg2.extras
from app import db_conf, app


@app.errorhandler(400)
def bad_request(e, code=400):
    return e, code


def authenticate(function):
    @wraps(function)
    def wrapper(*args, **kwargs):
        req = request.get_json()
        if 'user' in req and 'password' in req:
            conf = db_conf()
            conf['user'] = req['user']
            conf['password'] = req['password']
            try:
                connection = psycopg2.connect(**conf)
                cursor = connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
                cursor.execute('select user;')
                user = cursor.fetchone()
                result = function(user=user, connection=connection, cursor=cursor, *args, **kwargs)
                cursor.close()
                connection.close()
            except (Exception, psycopg2.Error) as error:
                print(error)
                return bad_request('Authentication failed, wrong username or password', 403)
            return result
        else:
            return bad_request('username or password was not provided!')

    return wrapper
