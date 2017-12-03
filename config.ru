#\ -p 3000 -s puma

require "erb"
require "rack"
require_relative "lib/git_status_middleware"

class App
  ERB.new(File.read("index.erb"))
     .def_method(self, "render(assigns)", "index.erb")

  def call(env)
    content = render(name: 'John Doe')
    [200, {"Content-Type" => "text/html", "Content-Length" => content.bytesize}, [content]]
  end
end

use GitStatusMiddleware
run App.new
