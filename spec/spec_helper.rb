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

  class RenderContext
    include Mold::Helpers
  end

  def render(file = nil, &block)
    @context = RenderContext.new

    if file
      path = File.expand_path("fixtures/#{file}", File.dirname(__FILE__))
      @template = Tilt::HamlTemplate.new(path, :format => :html5)
    else
      @template = Tilt::HamlTemplate.new(&block)
    end
    @output = @template.render(@context)
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

