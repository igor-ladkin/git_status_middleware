require "ostruct"
require "erb"

class GitStatus
  TEMPLATE_PATH = File.expand_path("template.erb", File.dirname(__FILE__))

  MODIFIED_CODES = ["A ", "D ", " D", "M ", " M"].freeze
  UNTRACKED_CODES = ["??"].freeze
  STAGED_CODES = ["A ", "D ", "M "].freeze

  def self.to_html(vars)
    ERB.new(File.read(TEMPLATE_PATH)).result(OpenStruct.new(vars).instance_eval { binding })
  end

  def to_h
    {
      branch: branch,
      revision: revision,
      changes: changes,
      error_message: error_message,
    }
  end

  def to_html
    self.class.to_html(to_h)
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
    begin
      `git rev-parse --is-inside-work-tree`.start_with?("true")
    rescue Errno::ENOENT
      false
    end
  end

  def status_string
    begin
      `git status -s -uall`.rstrip
    rescue Errno::ENOENT
      ''
    end
  end

  private

  def error_message
    case
    when !git_installed? then "Git is not installed. Install!"
    when !git_initialized? then "Git repository is not initialized. Initialize!"
    end
  end

  def branch
    return unless git_configured?
    `git rev-parse --abbrev-ref HEAD`.strip[0..25]
  end

  def revision
    return unless git_configured?
    `git rev-parse --verify HEAD`.strip[0..25]
  end

  def changes
    return unless git_configured?

    {
      modified: count_statuses(MODIFIED_CODES),
      untracked: count_statuses(UNTRACKED_CODES),
      staged: count_statuses(STAGED_CODES),
    }
  end

  def change_statuses
    status_string
      .split("\n")
      .map { |s| s[0..1] }
  end

  def count_statuses(codes)
    change_statuses.count { |status| codes.include?(status) }
  end
end
