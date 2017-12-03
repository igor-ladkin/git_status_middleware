require "erb"

class GitStatus
  ERB.new(File.read("lib/status.erb"))
     .def_method(self, "render_with_params(assigns)", "lib/status.erb")

  CHANDED_CODES = ["A ", "D ", " D", "M ", " M"].freeze
  UNTRACKED_CODES = ["??"].freeze
  STAGED_CODES = ["A ", "D ", "M "].freeze

  def to_h
    {
      branch: branch,
      revision: revision,
      changes: changes,
      error_message: error_message,
    }
  end

  def render
    render_with_params self.to_h
  end

  def git_configured?
    git_installed? && git_initialized?
  end

  def git_installed?
    begin
      `git --version`
    rescue Errno::ENOENT
      false
    end
  end

  def git_initialized?
    `git rev-parse --is-inside-work-tree`.start_with?("true")
  end

  def status_string
    `git status -s -uall`.strip
  end

  private

  def error_message
    case
    when !git_installed? then "Git is not installed. Install!"
    when !git_initialized? then "Git is not initialized. Initialize!"
    end
  end

  def branch
    return unless git_configured?
    `git rev-parse --abbrev-ref HEAD`.strip
  end

  def revision
    return unless git_configured?
    `git rev-parse --verify HEAD`.strip[0..10]
  end

  def changes
    return unless git_configured?
    formatted_changes
  end

  def change_statuses
    @change_statuses ||=
      status_string
        .split("\n")
        .map { |s| s[0..1] }
  end

  def change_counts
    {
      "C" => count_statuses(CHANDED_CODES),
      "U" => count_statuses(UNTRACKED_CODES),
      "S" => count_statuses(STAGED_CODES),
    }
  end

  def formatted_changes
    if change_counts.all? { |_k, count| count == 0 }
      "Nothing yet"
    else
      change_counts
        .map { |k, v| "#{k}: #{v}" }
        .join(", ")
    end
  end

  def count_statuses(codes)
    change_statuses.count { |status| codes.include?(status) }
  end

end
