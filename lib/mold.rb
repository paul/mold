require 'actionview'
require 'mold/action_view_extensions/form_helper'

module Mold
  Version = VERSION = "0.3.0"

  def version
    Version
  end

  autoload :FormBuilder, "mold/form_builder"
end
