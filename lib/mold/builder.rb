require 'haml'

module Mold
  class Builder

    attr_reader :name, :binding

    def initialize(object, binding, options = {}, &block)
      @name = object
      @binding = binding
      @parent = options[:parent_builder]
      @options = options
      @code = block
    end

    def to_html
      binding.capture_haml do
        if @parent.nil?
          binding.haml_tag :form, @options do
            @code.call(self)
          end
        else
          @code.call(self)
        end
      end
    end

    def nest(object, options = {}, &block)
      self.class.new(object, binding, options.merge(:parent_builder => self), &block).to_html
    end

    def nest_many(objects, options = {}, &block)
      nest(objects, options.merge(:many => true), &block)
    end

    def label(field, text = field, options = {})
      attributes = options.dup.merge(:for => field_id(field))
      binding.capture_haml { binding.haml_tag :label, text, attributes }
    end

    def input(field, options = {})
      attributes = attributes(field, options)
      binding.capture_haml { binding.haml_tag :input, attributes }
    end

    def select(field, choices = {}, options = {})
      attributes = attributes(field, options)
      binding.capture_haml { binding.haml_tag :select, attributes do 
        choices.each { |value,text| binding.haml_tag :option, text, :value => value }
      end
      }
    end

    def textarea(field, options = {})
      attributes = attributes(field, options)
      binding.capture_haml { binding.haml_tag :textarea, attributes }
    end

    def button(name, text, options = {})
      attributes = {:name => name}.merge(options)
      binding.capture_haml { binding.haml_tag :button, text, attributes }
    end

    def attributes(field, options = {})
      attributes = {
        :name => field_name(field),
        :id   => field_id(field)
      }

      attributes.merge(options)
    end

    def field_name(field)
      "#{name_prefix}[#{field}]"
    end

    def name_prefix
      if @parent
        prefix = "#{@parent.name_prefix}[#{name}]"
        prefix << "[]" if @options[:many]
        prefix
      else
        name
      end
    end

    def field_id(field)
      "#{id_prefix}_#{field}"
    end

    def id_prefix
      if @parent
        "#{@parent.id_prefix}_#{name}"
      else
        name
      end
    end

  end
end
