#!/usr/bin/env sh

if [[ ! -n $SAUCE_USERNAME ]]; then
  echo "SAUCE_USERNAME not set. Please set it to your Sauce OnDemand username to run these tests"
  exit 1
fi

if [[ ! -n $SAUCE_ACCESS_KEY ]]; then
  echo "SAUCE_ACCESS_KEY not set. Please set it to your Sauce OnDemand username to run these tests"
  exit 1
fi

if [[ -n $SAUCE_TEST_NO_LOCAL ]]; then
  echo "You have not set SAUCE_TEST_NO_LOCAL. Will run local Selenium tests against Firefox"
fi

if which rvm 2>&1 > /dev/null; then
  rvm use 1.8.7@sauce_gem_tests --create
  bundle install
  rake test TESTOPTS="-v"
else
  echo "You do not have RVM installed. Please install it and re-run this script."
fi
