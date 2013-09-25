module Sauce
  MAJOR_VERSION = '3.2'
  PATCH_VERSION = '0'

  def version
    "#{MAJOR_VERSION}.#{PATCH_VERSION}"
  end
  module_function :version
end
