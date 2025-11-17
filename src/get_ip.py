from flask import Flask, request, jsonify

app = Flask(__name__)


@app.route('/ip', methods=['GET', 'POST', 'HEAD'])
def get_ip():
    """Return the caller's IP address."""
    # Try various headers for IP address (in order of preference)
    ip = (
        request.headers.get('X-Forwarded-For', '').split(',')[0].strip() or
        request.headers.get('X-Real-IP') or
        request.remote_addr
    )
    
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
