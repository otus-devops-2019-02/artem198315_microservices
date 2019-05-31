FROM ubuntu:16.04

RUN apt-get update && \ 
apt-get install -y mongodb-server ruby-full ruby-dev build-essential git && \
gem install bundler && \
git clone -b monolith https://github.com/express42/reddit.git && \
cd /reddit && bundle install

COPY mongod.conf /etc/mongod.conf
COPY db_config /reddit/db_config
COPY start.sh /start.sh

RUN chmod 0777 /start.sh

EXPOSE 9292/tcp

CMD ["/start.sh"]

 
