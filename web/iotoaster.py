#!/usr/bin/env python3
from bottle import *

@route("/gettoasttime")
def gettoasttime():
    return "TOAST TIME: 120000."

run(host="0.0.0.0", port=8080)
