from app import app
from flask import request, jsonify
from connection import authenticate


@app.route('/get/candidates', methods=['GET'])
@authenticate
def fetch_candidate(user, connection):
    return f'nothing is the size of your penis, {user}'




