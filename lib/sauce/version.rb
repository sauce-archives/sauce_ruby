module Sauce
  MAJOR_VERSION = '3.4'
  PATCH_VERSION = '6'

  def version
    "#{MAJOR_VERSION}.#{PATCH_VERSION}"
  end
  module_function :version
end
