FROM python:3.11-slim

WORKDIR /function

# Copy function code
COPY src/get_ip.py /function/func.py

# Set the function entrypoint
ENV PYTHONUNBUFFERED=1

# OCI Functions expects the handler at func.handler
CMD ["python3", "-c", "from fdk import response; import func; response.RawResponse(ctx=None, response_data=func.handler(None, None), headers={}, status_code=200)"]

# For OCI Functions Python FDK
RUN pip install --no-cache-dir fdk
