FROM ruby:2.2-alpine as base

RUN apk update && apk --no-cache add make gcc libc-dev

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/

RUN gem install bundler -v 1.17.3 --no-ri --no-rdoc && bundle install --clean --no-cache

COPY . $APP_HOME

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

CMD ["puma"]

