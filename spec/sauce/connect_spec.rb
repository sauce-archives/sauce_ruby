require "spec_helper"

describe "Sauce::Connect" do
  describe "#connect" do
    context "skip_connection_test is false" do

      before do
        Sauce.clear_config
      end

      it "ensures it can gain access to Sauce Connect's servers" do
      end
    end

    context "skip_connection_test is true" do
      it "does not try to connect to Sauce Connect's servers" do
      end
    end
  end
  
end