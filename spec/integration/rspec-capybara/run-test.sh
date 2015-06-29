#!/bin/bash --login
gem install bundler
RAKE="bundle exec rake"

bundle install

${RAKE} spec