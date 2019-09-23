FROM python:3.6.0-alpine as base

FROM base as builder

RUN mkdir /build
WORKDIR /build
COPY requirements.txt /requirements.txt

RUN apk update && apk --no-cache add gcc python-dev musl-dev \
&& pip install --install-option="--prefix=/build" -r /requirements.txt

FROM base

COPY --from=builder /build /usr/local

COPY . /app
WORKDIR /app

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

CMD ["python3", "post_app.py"]


