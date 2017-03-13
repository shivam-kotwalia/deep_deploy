from flask import Flask, render_template
from deep_deploy import app

@app.route("/")
def index():
    return "Deep Deploy"

@app.errorhandler(404)
def error(e):
    # app.logger.error("Page not found, 404")
    # app.logger.info('Info')
    return "Error 404", 404

