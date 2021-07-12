from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
import os


app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql+psycopg2://saee:golabi@localhost:5432/election_db_project'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
# ma = Marshmallow(app)

# engine = create_engine('postgresql+psycopg2://saee:golabi@localhost:5432/election_db_project')

#
# class Asghar(db.Model):
#     name = db.Column(db.VARCHAR, primary_key=True)
#     size = db.Column(db.INT)
#
#     def __init__(self, name, size):
#         self.name = name
#         self.size = size
#
#
# db.create_all()
# db.session.commit()


@app.route('/')
def hello_world():
    a = db.session.query()
    print(*(i[0] for i in a))
    return jsonify({'msg': 'Hello World!'})


def create_people():
    for i in range(100000):
        name = f'random_name{i}'
        size = i
        db.engine.execute(f'insert into asghar values({name}, {size})')


if __name__ == '__main__':
    app.run(debug=True)
