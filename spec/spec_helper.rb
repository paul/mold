$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mold'
require 'spec'
require 'spec/autorun'
require 'pp'

require 'haml'
require 'tilt'
require 'webrat'#/core/matchers'

Spec::Runner.configure do |config|

  config.include Webrat::Matchers
  config.include Webrat::HaveTagMatcher

  class RenderContext
    include Mold::Helpers
  end

  config.before do
    @context = RenderContext.new
  end
  
end
