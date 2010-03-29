
module Mold
  module Helpers

    def mold(object, options = {}, &block)
      Builder.new(object, self, options, &block).to_html
    end

  end
end
