from flask import Flask, render_template
from .Registration.controller import mod_register
application = Flask(__name__)

application.register_blueprint(mod_register)