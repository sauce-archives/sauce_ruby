module Sauce
  MAJOR_VERSION = '2.4'
  PATCH_VERSION = '5'

  def version
    "#{MAJOR_VERSION}.#{PATCH_VERSION}"
  end
  module_function :version
end
