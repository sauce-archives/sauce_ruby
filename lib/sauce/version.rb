module Sauce
  MAJOR_VERSION = '2.5'
  PATCH_VERSION = '1'

  def version
    "#{MAJOR_VERSION}.#{PATCH_VERSION}"
  end
  module_function :version
end
