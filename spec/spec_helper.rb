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

end

Spec::Runner.configure do |config|

  config.include Webrat::Matchers
  config.include Webrat::HaveTagMatcher
  config.include RenderHelpers

end

