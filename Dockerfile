FROM --platform=linux/amd64 public.ecr.aws/docker/library/python:3.10-slim-buster as build

RUN apt update -y && \
    apt install -y build-essential libpq-dev && \
    pip install --upgrade pip setuptools wheel

WORKDIR /usr/src/app

COPY analytics .

RUN pip install -r requirements.txt

ENV DB_USERNAME=coworking
ENV DB_PASSWORD=mypassword
ENV DB_HOST=127.0.0.1
ENV DB_PORT=5433
ENV DB_NAME=coworking

EXPOSE 5153

CMD ["python", "app.py"]