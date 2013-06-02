#!/bin/bash -xe

RAKE="bundle exec rake"

# Resetting some environment variables in case our parent is running us via
# Rake
export GEM_HOME=
export GEM_PATH=
export BUNDLE_GEMFILE=
export BUNDLE_BIN_PATH=
export RUBYOPT=

# Make sure we load RVM into the shell properly
source ~/.rvm/scripts/rvm

bundle install

${RAKE} test
