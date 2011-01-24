require File.expand_path("../helper.rb", __FILE__)

class TestIntegrations < Test::Unit::TestCase
  def test_ruby18
    ensure_rvm_installed
    ruby_version = RVM.list_strings.find {|version| version =~ /ruby-1.8/}
    if ruby_version.nil?
      RVM.install "ruby-1.8.7"
    end
    Dir.entries(File.expand_path("../integrations", __FILE__)).find {|entry| entry =~ /\.rb$/ }.each do |integration_test|
      name = integration_test.split(".")[0]
      ruby18 = RVM.environment(ruby_version)
      gemset_name = "saucegem_#{name}"
      ruby18.gemset.create gemset_name
      begin
        puts "Running #{File.expand_path("../integrations/#{integration_test}", __FILE__)} with Ruby #{ruby_version}"
        output = ruby18.ruby(File.expand_path("../integrations/#{integration_test}", __FILE__))
        print output.stdout
        $stderr.print output.stderr
      ensure
        ruby18.gemset.delete gemset_name
      end
    end
  end


  #def test_ruby19
  #end
end
