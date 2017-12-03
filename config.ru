#\ -p 3000 -s puma

require "erb"
require "rack"

class App
  ERB.new(File.read("index.erb"))
     .def_method(self, "render(locals)", "index.erb")

  def call(env)
    content = render(name: 'John Doe')
    [200, {"Content-Type" => "text/html"}, [content]]
  end
end

run App.new
