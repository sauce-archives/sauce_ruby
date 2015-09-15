module Sauce
  MAJOR_VERSION = '3.5'
  PATCH_VERSION = '9'

  def version
    "#{MAJOR_VERSION}.#{PATCH_VERSION}"
  end
  module_function :version
end
