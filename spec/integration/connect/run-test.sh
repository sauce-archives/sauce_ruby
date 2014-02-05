#!/bin/bash -xe

RAKE="bundle exec rake"

bundle install

${RAKE} spec