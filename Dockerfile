FROM python:3.5
COPY ./src /code
WORKDIR /code
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DATABASE htmltopdf
RUN pip install -r requirements.txt
RUN apt-get update -y && apt-get install -Vy libreoffice unoconv
RUN apt-get install -y sqlite2 libsqlite3-dev
RUN pip freeze > requirements.txt