require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe 'Sauce::Connect integration testing' do
  def make_connection
    Sauce::Connect.new({})
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

    it 'should fail if the SAUCE_USERNAME is also empty' do
      expect {
        ENV['SAUCE_USERNAME'] = nil
        make_connection
      }.to raise_error(ArgumentError)
    end

    it 'should fail if the SAUCE_ACCESS_KEY is empty' do
      expect {
        ENV['SAUCE_USERNAME'] = 'testman'
        ENV['SAUCE_ACCESS_KEY'] = nil
        make_connection
      }.to raise_error(ArgumentError)

    end

    after :each do
      ENV['SAUCE_USERNAME'] = nil
    end
  end

  context 'assuming the "fail" username' do
    let(:conn) { Sauce::Connect.new(:host => 'saucelabs.com',
                                    :port => 80,
                                    :username => 'fail') }

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
