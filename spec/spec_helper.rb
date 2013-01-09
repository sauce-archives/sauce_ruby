$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

['sauce-jasmine', 'sauce-cucumber', 'sauce-connect'].each do |gem|
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../gems/#{gem}/lib"))
end

require 'sauce'

