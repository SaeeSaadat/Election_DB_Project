from app import app
from flask import request, jsonify
import psycopg2
from connection import authenticate


@app.route('/post/qualify', methods=['Post'])
@authenticate
def post_qualification(connection, cursor):
    req = request.get_json()
    typ = req['election_type']
    year = req['election_year']
    cursor.execute('select judge_id from judge_user_info;')
    judge = cursor.fetchone()
    if not judge:
        raise Exception('You ain\'t no judge')
    judge_id = judge.get('judge_id')
    candidate_id = req['candidate_id']
    vote = req['vote']
    cursor.execute(f"insert into qualification values ('{typ}' , {year} , {judge_id} , {candidate_id} ,{vote});")
    connection.commit()
    return 'Your qualification vote has been submitted your honor!'


@app.route('/update/qualification', methods=['Post'])
@authenticate
def update_qualification(connection, cursor):
    req = request.get_json()
    typ = req['election_type']
    year = req['election_year']
    cursor.execute('select judge_id from judge_user_info;')
    judge = cursor.fetchone()
    if not judge:
        raise Exception('You ain\'t no judge')
    judge_id = judge.get('judge_id')
    candidate_id = req['candidate_id']
    vote = req['vote']
    cursor.execute(f"update qualification set vote = {vote} "
                   f"where candidate_id = {candidate_id} and "
                   f"judge_id = {judge_id} and "
                   f"election_type = \'{typ}\' and "
                   f"election_year = {year};")
    connection.commit()
    return 'Your qualification vote has been submitted your honor!'


@app.route('/post/vote', methods=['Post'])
@authenticate
def post_vote(connection, cursor):
    req = request.get_json()
    typ = req['election_type']
    year = req['election_year']
    person_id = req['person_id']
    candidate_id = req['candidate_id']
    branch_no = req['branch_no']
    cursor.execute(f"insert into vote values (\'{typ}\' , {year} , {person_id} , {candidate_id} , {branch_no});")
    connection.commit()
    return 'Your vote means so little to us, but it was submitted anyway.'
