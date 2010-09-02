$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mold'
require 'spec'
require 'spec/autorun'
require 'pp'

require 'tilt'
require 'haml'
require 'erubis'
require 'nokogiri'
require 'webrat/core/matchers'

module RenderHelpers

  include Mold::Helpers

  def render(stuff = nil, &b)
    if block_given?
      @output = instance_eval(&b)
    else
      @output = stuff
    end
  end

  def render_haml(file)
    render_template(file, :haml, :format => :html5, :escape_html => false)
  end

  def render_erb(file)
    render_template(file, :erb)
  end

  def render_template(file, format, options = {})
    file = File.join(File.dirname(__FILE__), 'fixtures', "#{file}.html.#{format}")
    template = Tilt.new(file, options)
    @output = template.render(self)
  end

  def output
    @output
  end

  def it_should_have_label_and_input(opts = {})
    @field_name = opts[:name]
    @field_id   = opts[:id]

    output.should have_tag("form input[name='#{@field_name}']")
    output.should have_tag("form input[id=#{@field_id}]")
    output.should have_tag("form label[for=#{@field_id}]")
  end

end

Spec::Runner.configure do |config|

  require File.join(File.dirname(__FILE__), 'fixtures', 'mold_objects')
  config.include Spec::MoldObjects

  config.include Webrat::Matchers
  config.include Webrat::HaveTagMatcher
  config.include RenderHelpers

end

