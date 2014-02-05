#!/bin/bash --login

# Reset the environment and allow RVM to create its own
export BUNDLE_GEMFILE=
export GEM_HOME=
export GEM_PATH=
export BUNDLE_BIN_PATH=	
export RUBYOPT=
cd ../$1 && ./run-test.sh