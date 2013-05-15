require "rspec"
require "sauce"
require "parallel_tests"

describe "Sauce Rspec Runner" do
  describe "#self.tests_in_groups" do
    it "should return a group for every environment" do
      Sauce.config do |c|
        c.browsers = [
            ["Windows 7", "Opera", "10"],
            ["Linux", "Firefox", "19"],
            ["Windows 8", "Chrome", ""]
        ]
      end

      ParallelTests::Test::Runner.stub(:tests_in_groups).with(anything, anything, anything) {
        ["spec/one_spec", "spec/two_spec"]
      }
      test_groups = ParallelTests::Saucerspec::Runner.tests_in_groups ["spec/one_spec.rb"], "3"
      test_groups.length.should eq 6
    end
  end
end