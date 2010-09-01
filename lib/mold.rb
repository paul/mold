
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'mold/util'
require 'mold/builder'
require 'mold/helpers'

module Mold
  Version = VERSION = "0.2.0"

  def version
    Version
  end


end
