#!/bin/bash -xe

RAKE="bundle exec rake"

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
  test "my app", do
    page.open "/"
    assert page.is_text_present("Welcome aboard")
  end
end
EOF


${RAKE} db:migrate
${RAKE} test
${RAKE} test:selenium:sauce
