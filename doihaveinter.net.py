#!/usr/bin/python3

from bottle import route, run, template
import datetime, pytz

@route('/')
def index():
	response='<title>doihaveinter.net</title><h1>Yes</h1>\n as of ' + datetime.datetime.now(tz=pytz.utc).isoformat()
	return response

run(host='127.0.0.1', port=8000)
