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
    [status, updated_headers, updated_response]
  end

  def updated_headers
    updated_length = headers["Content-Length"].to_i + rendered_widget.bytesize
    headers.merge("Content-Length" => updated_length.to_s)
  end

  def updated_response
    if last_response.end_with?("</body></html>")
      last_response.insert(-15, rendered_widget)
    else
      last_response + rendered_widget
    end
  end

  private

  def rendered_widget
    @rendered_widget ||= git_status.render
  end

  def last_response
    response.last
  end
end
