require 'tagz'
require 'active_support/inflector/methods'

module Mold
  class Builder
    include Tagz

    attr_reader :name, :binding

    def initialize(name_or_object, binding, options = {}, &block)
      @binding = binding

      @name = extract_name(name_or_object, options)
      @object = extract_object(name_or_object, options)

      @parent = options[:parent_builder]
      @code = block

      form_id = "#{@name}_form"
      @options = { :name => @name, :id => form_id, :method => "POST" }
      @options.merge!(options)
    end

    def to_html
        if @parent.nil?
          tagz do
            form_(@options) do
              @code.call(self, @object) if @code
            end
          end
        else
          @code.call(self, @object) if @code
        end
    end

    def nest(object, options = {}, &block)
      self.class.new(object, binding, options.merge(:parent_builder => self), &block).to_html
    end

    def nest_many(objects, options = {}, &block)
      [objects].flatten.map do |object|
        nest(object, options.merge(:many => true), &block)
      end.join
    end

    def label(field, text = field, options = {})
      attributes = options.dup.merge(:for => field_id(field))
      tagz do
        label_(attributes) { text }
      end
    end

    def input(field, options = {})
      attributes = attributes(field, options)
      tagz do
        input_(attributes)
      end
    end

    def select(field, choices = {}, options = {})
      selected_value = options.delete(:value)
      attributes = attributes(field, options)
      tagz do
        select_(attributes) do
          choices.each { |value,text|
            option_attributes = {:value => value}
            option_attributes.merge!(:selected => :selected) if value == selected_value
            option_(option_attributes) { text }
          }
        end
      end
    end

    def textarea(field, options = {})
      value = options.delete(:value)
      attributes = attributes(field, options)
      tagz do
        textarea_(attributes) { value }
      end
    end

    def button(name, text, options = {})
      attributes = {:name => name}.merge(options)
      tagz do
        button_(attributes){text}
      end
    end

    def attributes(field, options = {})
      attributes = {
        :name => field_name(field),
        :id   => field_id(field)
      }

      if !options[:value] && @object.respond_to?(field)
        attributes[:value] = @object.send(field)
      end

      attributes.merge(options)
    end

    def field_name(field)
      "#{name_prefix}[#{field}]"
    end

    def name_prefix
      if @parent
        prefix = "#{@parent.name_prefix}[#{name}]"
        if @options[:many]
          prefix << (@object && @object.respond_to?(:id) ? "[#{@object.id}]" : "[]")
        end
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

    def extract_name(name_or_object, options)
      return name if name = options[:name]

      case name_or_object
      when String, Symbol
        name_or_object
      else
        ActiveSupport::Inflector.underscore(name_or_object.class.name)
      end

    end

    def extract_object(name_or_object, options)
      return object if object = options[:object]

      case name_or_object
      when String, Symbol
        nil
      else
        name_or_object
      end
    end


  end
end
