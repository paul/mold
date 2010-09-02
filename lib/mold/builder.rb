require 'options'
require 'haml'

require 'active_support/inflector/methods'

module Mold
  class Builder
    include Mold::Util

    attr_reader :binding

    def initialize(binding, *args, &block)
      @binding = binding

      args, options = Options.parse(args)
      @name, @object = name_and_object_from(args.first, options) if args.first

      @parent = options[:parent_builder]
      @code = block

      @options = { :method => "POST" }
      form_id = "#{@name}_form" if @name
      @options[:form_id] = form_id if form_id

      @options.merge!(options)
      @options[:method] = @options[:method].to_s.upcase
    end

    def to_html
      if @parent.nil?
        binding.capture_haml do
          binding.haml_tag(:form, @options) do
            binding.haml_concat(binding.capture_haml(self, @object, &@code))
          end
        end
      else
        binding.capture_haml(self, @object, &@code)
      end
    end
    alias to_s to_html

    def nest(object, options = {}, &block)
      nest_many(object, options = {}, &block) if object.is_a?(Array)

      self.class.new(binding, object, options.merge(:parent_builder => self), &block).to_html
    end

    def nest_many(objects, options = {}, &block)
      [objects].flatten.map do |object|
        nest(object, options.merge(:many => true), &block)
      end.join
    end

    def label(field, text = field, options = {})
      attributes = options.dup.merge(:for => field_id(field))
      tag(:label, text, attributes)
    end

    def input(field, options = {})
      attributes = attributes(field, options)
      tag(:input, attributes)
    end

    def select(field, choices = {}, options = {})
      selected_value = options.delete(:value)
      attributes = attributes(field, options)
      options = choices.map do |value,text|
        option_attributes = {:value => value}
        option_attributes.merge!(:selected => :selected) if value == selected_value
        tag(:option, text, option_attributes)
      end.join
      tag(:select, options, attributes)
    end

    def textarea(field, options = {})
      attributes = attributes(field, options)
      value = attributes.delete(:value)
      tag(:textarea, value, attributes)
    end

    def button(name, text, options = {})
      attributes = {:name => name}.merge(options)
      tag(:button, text, attributes)
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
        prefix = "#{@parent.name_prefix}[#{@name}]"
        if @options[:many]
          prefix << (@object && @object.respond_to?(:id) ? "[#{@object.id}]" : "[]")
        end
        prefix
      else
        @name
      end
    end

    def field_id(field)
      if id_prefix
        "#{id_prefix}_#{field}"
      else
        field
      end
    end

    def id_prefix
      if @parent
        prefix = "#{@parent.id_prefix}_#{@name}"
        if @options[:many] && @object && @object.respond_to?(:id)
          prefix << "_#{@object.id}"
        end
        prefix
      else
        @name
      end
    end

    def name_and_object_from(object, options)

      case object
      when String, Symbol
        name = object
        object = nil
      else
        name = ActiveSupport::Inflector.underscore(object.class.name).split('/').last
      end

      name   = options.getopt(:name,   default = name)
      object = options.getopt(:object, default = object)

      return name, object
    end

    protected

    def tag(*args, &block)
      binding.capture_haml do
        binding.haml_tag(*args, &block)
      end
    end


    def safe(output)
      return output            if output.nil?
      return output.html_safe  if defined?(ActiveSupport::SafeBuffer)
      return output.html_safe! if output.respond_to?(:html_safe!)
      output
    end

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
        return text
      end
      nil
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
