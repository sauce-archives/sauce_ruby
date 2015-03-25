#!/bin/bash --login

# Reset the environment and allow RVM to create its own
export BUNDLE_GEMFILE=
export RUBYOPT=

echo "Running tests in" $1
cd ../$1 && ./run-test.sh