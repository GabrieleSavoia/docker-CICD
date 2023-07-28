FROM python:3.10-alpine

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV HOME_APP /app

# creo gruppo 'app' e utente 'app'
RUN addgroup -S app && adduser -S app -G app

WORKDIR $HOME_APP

COPY requirements.txt .

RUN apk update \
    && apk add gcc musl-dev mariadb-connector-c-dev linux-headers

RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    pip install uwsgi

COPY . $HOME_APP

# Tutti i file copiati in $HOME_APP appartengono all'utente 'app' e gruppo 'app'
RUN chown -R app:app $HOME_APP

# Mi loggo come utente 'app' --> uwsgi eseguirà non più come root ma come utente 'app'
USER app

ENTRYPOINT ["sh", "entrypoint.sh"]
