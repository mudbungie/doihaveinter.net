from bottle import route, run, template
import datetime, pytz

@route('/')
def index():
	response='<title>doihaveinter.net</title><h1>Yes</h1>\n as of ' + datetime.datetime.now(tz=pytz.utc).isoformat()
	return response

run(host='0.0.0.0', port=80)
