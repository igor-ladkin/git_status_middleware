require "erb"

class GitStatusMiddleware
  ERB.new(File.read("lib/status.erb"))
     .def_method(self, "render(assigns)", "lib/status.erb")

  attr_reader :app, :status_string, :headers, :response

  def initialize(app)
    @app = app
  end

  def call(env)
    status, @headers, @response = app.call(env)
    [status, headers, updated_response]
  end

  def status_string
    @status_string ||= `git status -s -uall`
  end

  def updated_headers
  end

  def updated_response
    [
      @response.last[0..-15] + render(error_message: error_message, status: 'hello') + "</body></html>"
    ]
  end

  def git_installed?
    begin
      `git --version`
      true
    rescue Errno::ENOENT
      false
    end
  end

  def git_initialized?
    `git rev-parse --is-inside-work-tree`.start_with?("true")
  end

  private

  def error_message
    case
    when !git_installed? then "Git is not installed. Install!"
    when !git_initialized? then "Git is not initialized. Initialize!"
    end
  end
end
