require 'tagz'

module Mold
  Version = VERSION = "0.1.0"

  def version
    Version
  end

  module Helpers

    def mold(object, options = {}, &block)
      builder = Builder.new(object, options)
      yield builder
      builder.to_html
    end

  end

  class Builder

    attr_reader :name

    def initialize(object, options = {})
      @name = object
      @parent = options[:parent_builder]
      @options = options
      @output = ""
    end

    def nest(object, options = {}, &block)
      builder = self.class.new(object, options.merge(:parent_builder => self))
      yield builder
      @output << builder.to_html
    end

    def nest_many(objects, options = {}, &block)
      nest(objects, options.merge(:many => true), &block)
    end

    def input(field, options = {})
      options[:type] ||= :text
      attributes = attributes(field, options)
      @output << Tagz { input_(attributes){} } + "\n"
    end

    def select(field, choices = {}, options = {})
      attributes = attributes(field, options)
      @output << Tagz { select_(attributes){ choices.each { |value,text| option_(:value => value){ text } } } } + "\n"

    end

    def to_html
      @output
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
