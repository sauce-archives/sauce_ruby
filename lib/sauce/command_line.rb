require 'rest-client'

module Sauce
  class CommandLine
    def self.run
      verb = ARGV.first

      if "create" == verb
        puts "Let's create a new account!"
        print "Username: "
        username = $stdin.gets.chomp
        print "password: "
        password = $stdin.gets.chomp
        print "password confirmation: "
        password_confirmation = $stdin.gets.chomp
        print "email: "
        email = $stdin.gets.chomp
        print "Full name: "
        name = $stdin.gets.chomp

        # TODO: Add error handling, of course
        result = RestClient.post "http://ec2-184-72-130-71.compute-1.amazonaws.com:5000/rest/v1/users",
        {
          :username => username,
          :password => password,
          :password_confirmation => password_confirmation,
          :email => email,
          :token => "c8eb3e2645005bcbbce7e2c208c6b7a71555d908",
          :name => name
        }.to_json,
        :content_type => :json, :accept => :json

        puts result.inspect
      end

      return 0
    end
  end
end
