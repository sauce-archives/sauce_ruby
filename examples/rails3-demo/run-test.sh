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
# Make sure we load in our .rvmrc to use the right gemset
source .rvmrc

rm -rf test/selenium
rm -f lib/tasks/sauce.rake

bundle install
bundle exec ./script/rails generate sauce:install


# Create our test file, borrowed directly from the README
cat > test/selenium/simple_test.rb <<EOF
require "test_helper"

class DemoTest < Sauce::RailsTestCase
  test "my app" do
    s.get 'http://localhost:3001/'
    assert s.page_source.include? 'Welcome aboard'
  end
end
EOF


${RAKE} db:migrate
${RAKE} test
${RAKE} test:selenium:sauce
