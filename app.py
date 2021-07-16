from flask import Flask, request, jsonify
import json

app = Flask(__name__)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False


@app.route('/', methods=['GET', 'POST'])
def hello_world():
    return jsonify({'msg': 'go fuck yourself'})


def db_conf() -> dict:
    with open('db_config.json') as conf:
        data = json.load(conf)
        return data


if __name__ == '__main__':
    app.run(debug=True)

from routes import routes, post_routes