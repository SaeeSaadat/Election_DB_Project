from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy


app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql+psycopg2://saee:golabi@localhost:5432/election_db_project'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)


@app.route('/')
def hello_world():
    a = db.session.query()
    print(*(i[0] for i in a))
    return jsonify({'msg': 'Hello World!'})


def create_people():
    for i in range(100000):
        name = f'person-{i}'

        # db.engine.execute(f'insert into person values({name})')


if __name__ == '__main__':
    app.run(debug=True)
