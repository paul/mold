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

      contents = capture_html(self, @object, &@code) if @code
      contents = contents.join if contents.respond_to?(:join)

      if @parent.nil?
        concat_content(
          tagz do
            form_(@options) do
              contents
            end
          end
        )
      else
        concat_content(contents)
      end
    end
    alias to_s to_html

    def nest(object, options = {}, &block)
      nest_many(object, options = {}, &block) if object.is_a?(Array)

      self.class.new(object, binding, options.merge(:parent_builder => self), &block).to_html
    end

    def nest_many(objects, options = {}, &block)
      [objects].flatten.map do |object|
        nest(object, options.merge(:many => true), &block)
      end
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
        prefix = "#{@parent.id_prefix}_#{name}"
        if @options[:many] && @object && @object.respond_to?(:id)
          prefix << "_#{@object.id}"
        end
        prefix
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
        ActiveSupport::Inflector.underscore(name_or_object.class.name).split('/').last
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

    protected


    # These methods are stolen from SinatraMore

    # Captures the html from a block of template code for erb or haml
    # capture_html(&block) => "...html..."
    def capture_html(*args, &block)
      if binding.respond_to?(:is_haml?) && binding.is_haml?
        binding.block_is_haml?(block) ? binding.capture_haml(*args, &block) : block.call
      elsif has_erb_buffer?
        result_text = capture_erb(*args, &block)
        result_text.present? ? result_text : (block_given? && block.call(*args))
      else # theres no template to capture, invoke the block directly
        block.call(*args)
      end
    end

    # Outputs the given text to the templates buffer directly
    # concat_content("This will be output to the template buffer in erb or haml")
    def concat_content(text="")
      if binding.respond_to?(:is_haml?) && binding.is_haml?
        binding.haml_concat(text)
      elsif has_erb_buffer?
        erb_concat(text)
      else # theres no template to concat, return the text directly
        text
      end
    end

    # Retrieves content_blocks stored by content_for or within yield_content
    # content_blocks[:name] => ['...', '...']
    def content_blocks
      @content_blocks ||= Hash.new {|h,k| h[k] = [] }
    end

    # Used to capture the html from a block of erb code
    # capture_erb(&block) => '...html...'
    def capture_erb(*args, &block)
      erb_with_output_buffer { block_given? && block.call(*args) }
    end

    # Concats directly to an erb template
    # erb_concat("Direct to buffer")
    def erb_concat(text)
      @_out_buf << text if has_erb_buffer?
    end

    # Returns true if an erb buffer is detected
    # has_erb_buffer? => true
    def has_erb_buffer?
      !@_out_buf.nil?
    end

    # Used to determine if a block is called from ERB.
    # NOTE: This doesn't actually work yet because the variable __in_erb_template
    # hasn't been defined in ERB. We need to find a way to fix this.
    def block_is_erb?(block)
      has_erb_buffer? || block && eval('defined? __in_erb_template', block)
    end

    # Used to direct the buffer for the erb capture
    def erb_with_output_buffer(buf = '') #:nodoc:
      @_out_buf, old_buffer = buf, @_out_buf
      yield
      @_out_buf
    ensure
      @_out_buf = old_buffer
    end

  end
end
