require 'spec_helper'
require 'sauce/connect'

describe 'Sauce::Connect integration testing' do
  def make_connection
    Sauce::Connect.new({})
  end

  def backup_and_wipe_env_var(var)
    self.instance_variable_set("@env_#{var}",  ENV[var])
    ENV[var] = nil
  end

  def restore_env_var(var)
    value_of_variable = self.instance_variable_get("@env_#{var}")
    ENV[var] = value_of_variable unless value_of_variable.nil? 
  end

  before :each do
    Sauce.clear_config
  end

  context 'assuming valid Sauce Labs authentication' do
    # Defining a nil in the let since the before block will run after the let.
    # Running make_connection inside of a `let` block could end up with us
    # using the previous test's Sauce.config. BAD NEWS
    before :each do
      @conn = make_connection
    end

    it 'should have start with an uninitialized status' do
      @conn.status.should == 'uninitialized'
    end

    it 'should have a "running" status if the tunnel is connected' do
      @conn.connect
      @conn.wait_until_ready
      @conn.status.should == 'running'
    end

    after :each do
      @conn.disconnect if @conn
    end
  end

  context 'assuming an invalid/nonexistent username' do
    before :each do
      Sauce.config do |config|
        config[:username] = nil
        config[:access_key] = nil
      end
    end

    it 'should fail if the SAUCE_USERNAME is empty' do
      expect {
        backup_and_wipe_env_var "SAUCE_USERNAME"
        ENV['SAUCE_USERNAME'] = nil
        make_connection
      }.to raise_error(ArgumentError)
    end

    it 'should fail if the SAUCE_ACCESS_KEY is empty' do
      expect {
        backup_and_wipe_env_var "SAUCE_ACCESS_KEY"
        backup_and_wipe_env_var "SAUCE_USERNAME"

        ENV['SAUCE_USERNAME'] = 'testman'
        make_connection
      }.to raise_error(ArgumentError)

    end

    after :each do
      restore_env_var "SAUCE_USERNAME"
      restore_env_var "SAUCE_ACCESS_KEY"
    end
  end

  context 'assuming the "fail" username' do
    let(:conn) { Sauce::Connect.new(:host => 'saucelabs.com',
                                    :port => 80,
                                    :username => 'fail',
                                    :access_key => 'edededdedededeee') }

    it 'should set the error status' do
      start = Time.now
      conn.connect
      while ((Time.now - start) < 60) && !conn.error
        sleep 0.5
      end

      conn.error.should_not be nil
    end

    after :each do
      conn.disconnect
    end
  end
end
