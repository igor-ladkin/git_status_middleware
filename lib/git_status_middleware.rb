require_relative "git_status"

class GitStatusMiddleware
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
    full_response = response.join("")
    position = full_response.match("<body>")&.end(0) || 0

    [full_response.insert(position, git_status.to_html)]
  end
end
