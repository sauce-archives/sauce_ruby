require "spec_helper"

describe "Sauce::Utilities::RailsServer" do
  let (:server) {Sauce::Utilities::RailsServer.new}

  describe "##start_if_required" do
    context "With an :application_host in config" do
      it "starts" do
        config = {:start_local_application => true}
        fake_rails_server = double("Sauce::Utilities::RailsServer")
        expect(fake_rails_server).to receive(:start) {nil}
        expect(Sauce::Utilities::RailsServer).to receive(:new) {fake_rails_server}
        allow(Sauce::Utilities::RailsServer).to receive(:is_rails_app?) {true}

        Sauce::Utilities::RailsServer.start_if_required(config)
      end
    end
  end

  context "With a Rails 4 app" do
    before (:each) do
      File.stub(:exists?).and_return false
      File.stub(:exists?).with("bin/rails").and_return true
    end

    describe "#is_rails_app?" do
      it "should be true" do
        Sauce::Utilities::RailsServer.is_rails_app?.should be_true
      end
    end

    describe "#major_version" do
      it "should be 4" do
        Sauce::Utilities::RailsServer.major_version.should eq 4
      end
    end

    describe "#process_arguments" do
      it "returns bundle exec rails server" do
        expected_args = %w{bundle exec rails server}
        Sauce::Utilities::RailsServer.process_arguments.should eq expected_args
      end
    end
  end

  context "With a Rails 3 app" do
    before (:each) do
      File.stub(:exists?).and_return false
      File.stub(:exists?).with("script/rails").and_return true
    end

    describe "#is_rails_app?" do
      it "should be true" do
        Sauce::Utilities::RailsServer.is_rails_app?.should be_true
      end
    end

    describe "#major_version" do
      it "should be 3" do
        Sauce::Utilities::RailsServer.major_version.should eq 3
      end
    end

    describe "#process_arguments" do
      it "returns bundle exec rails server" do
        expected_args = %w{bundle exec rails server}
        Sauce::Utilities::RailsServer.process_arguments.should eq expected_args
      end
    end
  end

  context "Without a Rails app" do
    before (:each) do
      File.stub(:exists?).and_return false
    end

    describe "#is_rails_app?" do
      it "should be false" do
        Sauce::Utilities::RailsServer.is_rails_app?.should be_false
      end
    end
  end

  context "With a Rails 4 app" do
    before (:each) do
      File.stub(:exists?).and_return false
      File.stub(:exists?).with("bin/rails").and_return true
    end

    describe "#is_rails_app?" do
      it "should be true" do
        Sauce::Utilities::RailsServer.is_rails_app?.should be_true
      end
    end

    describe "#major_version" do
      it "should be 4" do
        Sauce::Utilities::RailsServer.major_version.should eq 4
      end
    end

    describe "#process_arguments" do
      it "returns bundle exec rails server" do
        expected_args = %w{bundle exec rails server}
        Sauce::Utilities::RailsServer.process_arguments.should eq expected_args
      end
    end
  end
end