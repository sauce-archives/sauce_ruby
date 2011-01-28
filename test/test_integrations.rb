require File.expand_path("../helper.rb", __FILE__)

class TestIntegrations < Test::Unit::TestCase
  def setup
    ensure_rvm_installed
    Dir.chdir File.expand_path("../..", __FILE__) do
      system("gem build sauce.gemspec")
    end
    ENV['SAUCE_GEM'] = File.expand_path("../../"+Dir.entries(".").select {|f| f =~ /sauce-.*.gem/}.sort.last, __FILE__)
  end

  def test_ruby18
    ruby_version = RVM.list_strings.find {|version| version =~ /ruby-1.8/}
    if ruby_version.nil?
      RVM.install "ruby-1.8.7"
    end
    ruby_version = RVM.list_strings.find {|version| version =~ /ruby-1.8/}
    run_with_ruby(ruby_version)
  end

  def test_ruby19
    ruby_version = RVM.list_strings.find {|version| version =~ /ruby-1.9/}
    if ruby_version.nil?
      RVM.install "ruby-1.9.2"
    end
    ruby_version = RVM.list_strings.find {|version| version =~ /ruby-1.9/}
    run_with_ruby(ruby_version)
  end

  def run_with_ruby(ruby_version)
    Dir.entries(File.expand_path("../integrations", __FILE__)).find {|entry| entry =~ /\.rb$/ }.each do |integration_test|
      name = integration_test.split(".")[0]
      test_file = File.expand_path("../integrations/#{integration_test}", __FILE__)
      rubie = RVM.environment(ruby_version)
      gemset_name = "saucegem_#{name}"
      rubie.gemset.create gemset_name
      begin
        rubie = RVM.environment("#{ruby_version}@#{gemset_name}")
        output = rubie.ruby("\"#{test_file}\"")
        unless output.successful?
          puts "==== #{test_file} with Ruby #{ruby_version} ===="
          puts "===== STDOUT ====="
          print output.stdout
          puts "===== STDERR ====="
          $stderr.print output.stderr
          puts "===== END ====="
        end
        assert output.successful?, "#{integration_test} failed on Ruby #{ruby_version}"
      ensure
        rubie.gemset.delete gemset_name
      end
    end

  end
end
