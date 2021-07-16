from app import app
from flask import request, jsonify
import psycopg2
from connection import bad_request

conf = {'host': 'localhost', 'database': 'election_db_project', 'user': 'asghar', 'password': 'golabi'}


@app.route('/regionalresult/<region>')
@app.route('/regionalresult/')
def fetch_regional_result(region=None):
    try:
        connection = psycopg2.connect(**conf)
        cursor = connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        try:
            if region:
                cursor.execute(f'select * from detailed_region_res where region_id = {region};')
            else:
                cursor.execute('select * from detailed_region_res;')
            res = cursor.fetchall()
        except (psycopg2.Error, Exception) as err:
            print(err)
            return bad_request(f'{err}', 403)

        cursor.close()
        connection.close()
    except (Exception, psycopg2.Error) as error:
        print(error)
        return bad_request('Authentication failed, wrong username or password', 403)
    return jsonify(res if len(res) != 1 else res[0])


@app.route('/minorityresult/<minority>')
def fetch_minority_result(minority):
    try:
        connection = psycopg2.connect(**conf)
        cursor = connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        try:
            cursor.execute(f'select * from detailed_minority_res where religion_minority = \'{minority}\';')
            res = cursor.fetchall()
        except (psycopg2.Error, Exception) as err:
            print(err)
            return bad_request(f'{err}', 403)

        cursor.close()
        connection.close()
    except (Exception, psycopg2.Error) as error:
        print(error)
        return bad_request('Authentication failed, wrong username or password', 403)
    return jsonify(res if len(res) != 1 else res[0])


@app.route('/get/all/<what>')
def get_all_judges(what):
    if what == 'judges':
        view = "all_judges_info"
        id = 'judge_id'
    elif what == 'candidates':
        view = "all_candidates_info"
        id = 'candidate_id'

    try:
        connection = psycopg2.connect(**conf)
        cursor = connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        try:
            cursor.execute(f'select name, {id}, age from {view};')
            res = cursor.fetchall()
        except (psycopg2.Error, Exception) as err:
            print(err)
            return bad_request(f'{err}', 403)

        cursor.close()
        connection.close()
    except (Exception, psycopg2.Error) as error:
        print(error)
        return bad_request('Authentication failed, wrong username or password', 403)
    return jsonify(res if len(res) != 1 else res[0])


@app.route('/get/rejections')
def get_rejections():
    try:
        connection = psycopg2.connect(**conf)
        cursor = connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        try:
            cursor.execute(f'select * from rejections;')
            res = cursor.fetchall()
        except (psycopg2.Error, Exception) as err:
            print(err)
            return bad_request(f'{err}', 403)

        cursor.close()
        connection.close()
    except (Exception, psycopg2.Error) as error:
        print(error)
        return bad_request('Authentication failed, wrong username or password', 403)
    return jsonify(res if len(res) != 1 else res[0])