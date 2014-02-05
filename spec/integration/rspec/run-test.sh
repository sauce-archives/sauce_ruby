#!/bin/bash --login
RAKE="bundle exec rake"

bundle install

${RAKE} spec