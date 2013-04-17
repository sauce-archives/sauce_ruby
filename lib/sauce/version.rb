module Sauce
  MAJOR_VERSION = '2.3'
  PATCH_VERSION = '7'

  def version
    "#{MAJOR_VERSION}.#{PATCH_VERSION}"
  end
  module_function :version
end
