FROM ruby:2.4.3-slim

MAINTAINER Yale University ITS <cct-app-dev@yale.edu>

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

COPY Gemfile* ./
RUN gem install bundler && bundle install --jobs 20 --retry 5 --without development test

COPY . ./

RUN mv ./config/database.yml.example ./config/database.yml

CMD bundle exec puma -p $PORT -C ./config/puma.rb
