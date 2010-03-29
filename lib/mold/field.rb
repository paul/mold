require 'options'
require 'haml'

module Mold
  class Field
    include Haml::Helpers

    attr_accessor :binding, :name, :attributes, :content

    def initialize(*args)
      args, options = Options.parse(args)
      @binding = args.shift
      @name = args.shift
      @content = (block_given? ? block : args.shift)
      @attributes = options
    end



    def to_html
      init_haml_helpers
      capture_haml { haml_tag name, content, attributes }
    end

  end
end
