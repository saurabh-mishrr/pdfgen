from flask import Flask, Blueprint, request, make_response, jsonify, Response

mod_register = Blueprint('controller', __name__, url_prefix='/auth')


@mod_register.route('/register', methods = ['GET'])
def register():
    res = make_response(jsonify({'msg': 'W00t'}))
    res.headers['Content-type'] = 'application/json'
    return res