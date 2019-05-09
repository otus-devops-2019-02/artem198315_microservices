FROM ruby:2.2-alpine as base

FROM base as builder

RUN apk update && apk --no-cache add make gcc libc-dev

WORKDIR /
COPY Gemfile* /
RUN bundle install --clean --no-cache

FROM base

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY --from=builder /usr/local/bundle  /usr/local/bundle
COPY . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]

