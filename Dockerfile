FROM python:3.10-alpine

# ENVS
ENV PYTHONUNBUFFERED=1

WORKDIR src

# Install system requirements
RUN apk add --update --no-cache --virtual .tmp \
        python3-dev build-base linux-headers pcre-dev \
        jpeg-dev zlib-dev \        
        postgresql-dev

RUN apk add --no-cache --update libpq

# Install python requirements
COPY Pipfile* .

RUN pip install --no-cache-dir pipenv
RUN pipenv install --system

# Clear caches and temps
RUN pipenv --clear \
    && apk del .tmp \
    && adduser -D django 

# Copy source code
COPY ./src .

# Run application
EXPOSE 8000 8080

USER django

CMD ["uwsgi", "--http", "0.0.0.0:8080", "--master", "--enable-threads", "--module", "config.wsgi"]