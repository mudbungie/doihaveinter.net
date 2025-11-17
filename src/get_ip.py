from flask import Flask, request, jsonify
import datetime

app = Flask(__name__)


def get_ip_from_request() -> str:
    """Extract IP address from request headers."""
    # Try various headers for IP address (in order of preference)

    ip = (
        request.headers.get('X-Forwarded-For', '').split(',')[0].strip() or
        request.headers.get('X-Real-IP') or
        request.remote_addr
        or 'Unknown'
    )
    
    return ip


@app.route('/ip', methods=['GET', 'POST', 'HEAD'])
def get_ip():
    """Return just the IP address"""
    return get_ip_from_request()

@app.route('/IP', methods=['GET', 'POST', 'HEAD'])
def get_ip_upper():
    """Return just the IP address with endline"""
    return get_ip_from_request() + '\n'

@app.route('/ip.json', methods=['GET', 'POST', 'HEAD'])
def get_ip_json():
    """Return the IP address in JSON format."""
    ip = get_ip_from_request()
    return jsonify({"ip": ip})

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({"status": "ok"})


@app.route('/', methods=['GET'])
def root():
    """Returns a simple html string that includes the current time and the word YES."""
    html = f"""<html>
<head>
<title>Do I have Internet?</title>
</head>
<body>
<h1>Yes</h1>
as of {datetime.datetime.now().isoformat()} UTC
from IP: {get_ip_from_request()}
<br><br>
Use /ip to get just your IP address, /IP for that and an endline, or /ip.json for JSON format.
<br><br>
</body>
</html>
"""
    return html


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
