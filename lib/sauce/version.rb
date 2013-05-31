module Sauce
  MAJOR_VERSION = '3.0'
  PATCH_VERSION = '0.beta.2'

  def version
    "#{MAJOR_VERSION}.#{PATCH_VERSION}"
  end
  module_function :version
end
