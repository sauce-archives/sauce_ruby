module Sauce
  MAJOR_VERSION = '3.5'
  PATCH_VERSION = '10'

  def version
    "#{MAJOR_VERSION}.#{PATCH_VERSION}"
  end
  module_function :version
end
