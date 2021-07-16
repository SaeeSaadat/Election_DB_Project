from app import app
from flask import request, jsonify
import psycopg2
from connection import authenticate


@app.route('/get/person', methods=['GET'])
@authenticate
def fetch_user(connection, cursor):
    cursor.execute(f"select * from people;")
    res = cursor.fetchall()
    print(*(i for i in res))
    return jsonify(res[0] if res else [])


@app.route('/get/allcandidates')
@authenticate
def fetch_all_candidates(connection, cursor):
    cursor.execute(f"select * from visible_candidates;")
    res = cursor.fetchall()
    return jsonify(res)


@app.route('/get/candidates')
@authenticate
def fetch_candidates(connection, cursor):
    cursor.execute(f"select * from people;")
    usr = cursor.fetchone()
    user_region = usr.get('region_id')
    print(user_region)
    cursor.execute(f"select * from visible_candidates where region_id = {user_region};")
    res = cursor.fetchall()
    return jsonify(res)


@app.route('/get/result')
@authenticate
def fetch_result(connection, cursor):
    cursor.execute('select * from election_result;')
    return jsonify(cursor.fetchall())


@app.route('/get/myvotes')
@authenticate
def fetch_my_votes(connection, cursor):
    cursor.execute('select * from user_votes;')
    return jsonify(cursor.fetchall())


@app.route('/get/branches')
@authenticate
def fetch_branches(connection, cursor):
    cursor.execute(
        'select * from region_info;'
    )
    res = cursor.fetchall()
    return jsonify(res if len(res) != 1 else res[0])
