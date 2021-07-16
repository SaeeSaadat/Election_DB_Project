from app import app
from flask import request, jsonify
import psycopg2
from connection import authenticate


@app.route('/candidate/request', methods=['GET'])
@authenticate
def candidation_requast(connection, cursor):
    return jsonify('sorry but we\r not accepting applicants now')


@app.route('/candidate/qualification')
@authenticate
def candidate_qualification(connection, cursor):
    cursor.execute(f'select * from qualification_votes')
    res = cursor.fetchall()
    return jsonify(res if len(res) != 1 else res[0])


@app.route('/candidate/votes')
@authenticate
def candidate_votes(connection, cursor):
    cursor.execute(f'select * from candidate_users_info;')
    can = cursor.fetchone()
    if not can:
        raise Exception('You ain\'t no candidate! no one votes for you, no one even likes you!')

    candidate_id = can.get('candidate_id')

    cursor.execute(
        f'select * from election_result where candidate_id = {candidate_id} ;')
    res = cursor.fetchall()
    return jsonify(res if len(res) != 1 else res[0])


