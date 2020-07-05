FROM python:alpine3.10

WORKDIR /usr/sliceit/

COPY requirements.txt /usr/sliceit/

RUN \
 #apk add --no-cache python3 postgresql-libs && \
 #apk add --no-cache --virtual .build-deps gcc python3-dev musl-dev postgresql-dev && \
 python3 -m pip install -r requirements.txt --no-cache-dir
 #apk --purge del .build-deps

COPY run.py /usr/sliceit

COPY gunicorn_conf.py /usr/sliceit

COPY /app /usr/sliceit/app/

CMD gunicorn -c gunicorn_conf.py run:app
