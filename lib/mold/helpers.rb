
module Mold
  module Helpers

    def mold(*args, &block)
      Builder.new(self, *args, &block).to_html
    end

  end
end
