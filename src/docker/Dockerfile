FROM ubuntu

COPY ./src/webserver/doihaveinter.net.py /opt/doihaveinter.net/

RUN apt update ; apt upgrade

RUN apt install -y python3
RUN apt install -y python3-pip

RUN pip3 install bottle pytz

# to run: 
# podman run --rm -p 8080:8000 doihaveinter.net python3 /opt/doihaveinter.net/doihaveinter.net.py