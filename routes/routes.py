from app import app
from flask import request, jsonify
import psycopg2
from connection import authenticate


@app.route('/get/person', methods=['GET'])
@authenticate
def fetch_candidate(user, connection, cursor):
    cursor.execute(f"select * from people;")
    res = cursor.fetchall()
    print(*(i for i in res))
    return jsonify(res[0] if res else [])




