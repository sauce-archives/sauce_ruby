module Sauce
  MAJOR_VERSION = '3.3'
  PATCH_VERSION = '1'

  def version
    "#{MAJOR_VERSION}.#{PATCH_VERSION}"
  end
  module_function :version
end
