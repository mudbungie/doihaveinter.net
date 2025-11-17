from flask import Flask, request, jsonify

app = Flask(__name__)


def get_ip_from_request():
    """Extract IP address from request headers."""
    # Try various headers for IP address (in order of preference)

    ip = (
        request.headers.get('X-Forwarded-For', '').split(',')[0].strip() or
        request.headers.get('X-Real-IP') or
        request.remote_addr
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
    """Root endpoint."""
    return jsonify({"message": "IP address service", "endpoints": ["/ip", "/health"]})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
