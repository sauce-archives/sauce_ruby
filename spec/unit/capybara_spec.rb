require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sauce::Capybara do
  describe '#connect_tunnel' do
    before :each do
      $sauce_tunnel = nil
    end

    let(:connector) do
      connector = double()
      connector.should_receive(:connect)
      connector.should_receive(:wait_until_ready)
      connector
    end

    it 'should not do anything if the sauce tunnel exists' do
      $sauce_tunnel = 1337
      Sauce::Capybara.connect_tunnel.should == 1337
    end

    it 'should connect if the tunnel is not connected' do
      Sauce::Connect.should_receive(:new).and_return(connector)

      Sauce::Capybara.connect_tunnel
    end

    it 'should pass the quiet option to Sauce::Connect' do
      Sauce::Connect.should_receive(:new).with(
                    hash_including(:quiet => true)).and_return(connector)
      Sauce::Capybara.connect_tunnel(:quiet => true)
    end

    after :each do
      $sauce_tunnel = nil
    end
  end

  describe Sauce::Capybara::Driver do
    describe '#browser' do
      before :each do
        # Stub out the selenium driver startup
        Sauce::Selenium2.stub(:new).and_return(nil)
      end
      context 'when tunneling is disabled' do
        it 'should not call #connect_tunnel' do
          Sauce::Capybara.should_receive(:connect_tunnel).never
          Sauce.config do |c|
            c[:start_tunnel] = false
          end

          driver = Sauce::Capybara::Driver.new(nil)
          driver.browser
        end
      end
    end

  end

  describe '#install_hooks' do
  end
end

describe Sauce::Capybara::Cucumber do
  include Sauce::Capybara::Cucumber
  describe '#use_sauce_driver' do
    before :each do
      ::Capybara.current_driver = :test
    end

    it 'should change Capybara.current_driver to :sauce' do
      use_sauce_driver
      ::Capybara.current_driver.should == :sauce
    end
  end

  describe 'generating job names' do
    context 'with a simple, standard scenario' do
      let(:scenario) do
        s = double('Cucumber::AST::Scenario')
        s.stub(:name).and_return('This is a simple scenario')
        s
      end
      let(:feature) do
        f = double('Cucumber::AST::Feature')
        f.stub(:short_name).and_return('A simple feature')
        f
      end

      before :each do
        scenario.stub(:feature).and_return(feature)
      end

      describe '#name_from_scenario' do
        it 'should generated a useful name' do
          expected = 'A simple feature - This is a simple scenario'
          name_from_scenario(scenario).should == expected
        end
      end

      describe 'jenkins_name_from_scenario' do
        it 'should generate the dotted name the Jenkins plugin wants' do
          expected = 'A simple feature.This is a simple scenario.This is a simple scenario'
          jenkins_name_from_scenario(scenario).should == expected
        end
      end
    end
  end
end
