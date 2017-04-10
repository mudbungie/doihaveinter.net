#!/usr/bin/python3

from bottle import route, run, request
import datetime, pytz

@route('/')
def index():
	return '<title>doihaveinter.net</title><h1>Yes</h1>\n as of ' + datetime.datetime.now(tz=pytz.utc).isoformat()

@route('/ip')
def ip():
	return request.environ['HTTP_X_REAL_IP']

@route('/ip')
def ip():
	return '{}\n'.format(request.environ['HTTP_X_REAL_IP'])

run(host='127.0.0.1', port=8000)
