from app import app
from flask import request

@app.route('/internal')
def internal():
    return "internal"


@app.route('/external')
def external():
    return "external"

@app.route('/cached')
def cached():
    return "cached"
