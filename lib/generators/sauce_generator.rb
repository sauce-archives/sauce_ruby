class SauceGenerator < Rails::Generators::Base
  def self.source_root
    @source_root ||= File.join(File.dirname(__FILE__), 'templates')
  end
  def copy_initializer_file
    template "sauce.rake", "lib/tasks/sauce.rake"
  end
end
