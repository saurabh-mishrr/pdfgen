FROM python:3.5
COPY ./src /code
WORKDIR /code
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
RUN pip install -r requirements.txt