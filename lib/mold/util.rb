require 'tagz'

module Mold
  module Util

    def self.escape(string)
      Tagz.xchar.escape(string)
    end

    def escape(string)
      self.class.escape(string)
    end
  end
end
