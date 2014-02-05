#!/bin/bash -xe
RAKE="bundle exec rake"

bundle install
bundle exec cucumber -f pretty