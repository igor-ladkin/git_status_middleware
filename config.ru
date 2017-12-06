#\ -p 3000 -s puma

require "ostruct"
require "erb"
require "rack"
require_relative "lib/git_status_middleware"

class App
  TEMPLATE_PATH = File.expand_path("index.erb", File.dirname(__FILE__))

  def self.to_html(vars)
    ERB.new(File.read(TEMPLATE_PATH)).result(OpenStruct.new(vars).instance_eval { binding })
  end

  def call(env)
    content = self.class.to_html(message: "Hi Bob!")
    [200, {"Content-Type" => "text/html", "Content-Length" => content.bytesize.to_s}, [content]]
  end
end

use GitStatusMiddleware
run App.new
