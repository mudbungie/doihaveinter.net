import io
import json


def get_caller_ip(data):
    """
    Extract the caller's IP address from OCI Function context.
    
    The context data comes from the API Gateway which includes
    the requestContext with the caller's IP in the 'identity' section.
    """
    try:
        # Parse the input data
        if isinstance(data, (bytes, bytearray)):
            body = json.loads(data)
        elif isinstance(data, io.BytesIO):
            body = json.loads(data.getvalue())
        elif isinstance(data, str):
            body = json.loads(data)
        elif isinstance(data, dict):
            body = data
        else:
            return {"error": "Invalid input format"}
        
        print(body) # Debugging: print the body to verify structure #DELETEME

        # Extract IP from the request context
        # OCI API Gateway provides the client IP in requestContext.identity.sourceIp
        ip_address = body.get("requestContext", {}).get("identity", {}).get("sourceIp")
        
        if ip_address:
            return {"ip": ip_address}
        else:
            return {"error": "IP address not found in request context"}
            
    except json.JSONDecodeError:
        return {"error": "Invalid JSON payload"}
    except Exception as e:
        return {"error": f"Failed to process request: {str(e)}"}


def handler(ctx, data: io.BytesIO = None):
    """
    OCI Function handler entry point.
    """
    result = get_caller_ip(data)
    return result
