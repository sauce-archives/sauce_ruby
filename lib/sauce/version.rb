module Sauce
  MAJOR_VERSION = '3.1'
  PATCH_VERSION = '3'

  def version
    "#{MAJOR_VERSION}.#{PATCH_VERSION}"
  end
  module_function :version
end
