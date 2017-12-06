require_relative "git_status"

class GitStatusMiddleware
  attr_reader :app, :git_status, :status, :headers, :response

  def initialize(app)
    @app = app
    @git_status = GitStatus.new
  end

  def call(env)
    @status, @headers, @response = app.call(env)
    [status, updated_headers, updated_response]
  end

  def updated_headers
    headers.merge("Content-Length" => updated_response.first.bytesize.to_s)
  end

  def updated_response
    return response unless html_request? && status_ok?
    [contatinated_response.insert(position_after_body_tag, rendered_widget)]
  end

  private

  def rendered_widget
    git_status.to_html
  end

  def contatinated_response
    case
    when response.respond_to?(:join) then response.join("")
    when response.respond_to?(:body) then response.body
    end
  end

  def position_after_body_tag
    contatinated_response.match("<body>")&.end(0) || 0
  end

  def html_request?
    headers["Content-Type"] == "text/html"
  end

  def status_ok?
    status == 200
  end
end
