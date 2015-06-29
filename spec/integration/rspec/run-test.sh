#!/bin/bash --login
gem install bundler

RAKE="bundle exec rake"
bundle update

${RAKE} spec