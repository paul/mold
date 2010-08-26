$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mold'
require 'spec'
require 'spec/autorun'
require 'pp'

require 'haml'
require 'tilt'
require 'nokogiri'
require 'webrat/core/matchers'

module RenderHelpers

  include Mold::Helpers

  def render(file = nil, &block)
    @context = self

    if file
      path = File.expand_path("fixtures/#{file}", File.dirname(__FILE__))
      @template = Tilt::HamlTemplate.new(path, :format => :html5)
    else
      @template = Tilt::HamlTemplate.new(:format => :html5, &block)
    end
    @output = @template.render(@context)
  end

  def render_haml(content)
    render {
      strip_indents(content)
    }
  end

  def strip_indents(string)
    i = string.index(/[^\s]/)
    string.gsub(/^ {#{i-1}}/, '')
  end

  def output
    @output
  end

  def it_should_have_label_and_input(opts = {})
    @field_name = opts[:name]
    @field_id   = opts[:id]

    output.should have_tag(:input, :name => @field_name)

    output.should have_tag(:input, :id => @field_id)

    output.should have_tag(:label, :for => @field_id)

  end

end

Spec::Runner.configure do |config|

  config.include Webrat::Matchers
  config.include Webrat::HaveTagMatcher
  config.include RenderHelpers

end

