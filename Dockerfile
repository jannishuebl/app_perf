FROM ruby:2.3

# get Gem and app specific libs installed 
RUN apt-get update -qq && apt-get install -y build-essential \
    libpq-dev \
    libqt4-dev \
    libqt4-webkit \
    libreadline-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    nodejs \
    nodejs-legacy \
    npm \
    vim \
    xvfb \
    zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

# Phantom JS
RUN npm install -g phantomjs

RUN apt-get clean

# This docker file is not wholly meant for Prod. It is firstly designed for SOA Development of all apps
# Must use root for local OSX dev for now. will replace with NFS/SMB later?
#
USER root
ENV DEPLOY_HOME /root
ENV APP_HOME /app
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bash -lc 'bundle install' \
  # get the file size down on the final docker image
  && find / -name doc | xargs rm -rf \
  && apt-get clean autoclean \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt /var/lib/cache /var/lib/log #/var/lib/dpkg

ADD . $APP_HOME
RUN bash -l -c 'RAILS_ENV=production bundle exec rake assets:precompile'

RUN mkdir -p tmp/pids
RUN mv config/database.yml.docker config/database.yml
