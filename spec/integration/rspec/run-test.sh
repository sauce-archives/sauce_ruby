#!/bin/bash --login
rvm current

RAKE="bundle exec rake"
bundle update

${RAKE} spec