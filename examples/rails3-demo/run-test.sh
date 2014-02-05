#!/bin/bash -xe
RAKE="bundle exec rake"

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