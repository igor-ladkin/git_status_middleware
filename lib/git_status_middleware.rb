require "erb"
require_relative "git_status"

class GitStatusMiddleware
  ERB.new(File.read("lib/status.erb"))
     .def_method(self, "render(assigns)", "lib/status.erb")

  attr_reader :app, :git_status, :headers, :response

  def initialize(app)
    @app = app
    @git_status = GitStatus.new
  end

  def call(env)
    status, @headers, @response = app.call(env)
    [status, headers, updated_response]
  end

  def updated_headers
  end

  def updated_response
    [
      @response.last[0..-15] + git_status.render + "</body></html>"
    ]
  end
end
