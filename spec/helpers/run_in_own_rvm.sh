#!/bin/bash

# Reset the environment and allow RVM to create its own
unset BUNDLE_GEMFILE
unset BUNDLE_BIN_PATH
unset RUBYOPT

echo "Running tests in" $1
cd ../$1 && ./run-test.sh