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
    judge_id = req['judge_id']
    candidate_id = req['candidate_id']
    vote = req['vote']
    cursor.execute(f"insert into qualification values ({typ} , {year} , {judge_id} , {candidate_id} ,{vote});")
    connection.commit()


@app.route('/post/vote', methods=['Post'])
@authenticate
def post_vote(connection, cursor):
    req = request.get_json()
    typ = req['election_type']
    year = req['election_year']
    person_id = req['person_id']
    candidate_id = req['candidate_id']
    branch_no = req['branch_no']
    cursor.execute(f"insert into vote values ({typ} , {year} , {person_id} , {candidate_id} , {branch_no});")
    connection.commit()
