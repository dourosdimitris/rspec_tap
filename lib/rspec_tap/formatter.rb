require "yaml"
require "rspec/core/formatters/base_text_formatter"

module RspecTap
  class Formatter < RSpec::Core::Formatters::BaseTextFormatter
    RSpec::Core::Formatters.register self,
      :start,
      :example_group_started,
      :example_started,
      :example_passed,
      :example_failed

    def initialize(stdout)
      @progress_count = 0
      super(stdout)
    end

    def example_started(notification)
      @progress_count += 1
    end

    def start(notification)
      super(notification)
      output.puts "1..#{notification.count}"
    end

    def example_passed(notification)
      example_line(description: notification.example.description)
    end

    def example_failed(notification)
      example_line(
        status:      "not ok",
        description: notification.example.description
      )
      diagnostic(notification)
    end

    def example_pending(notification)
      example_line(
        description: notification.example.description,
        directive:   "# SKIP"
      )
    end

    def dump_failures(*args)
      # No-op. We already output failure info inline
    end

    private

    def example_line(status: "ok", description: "", directive: "")
      output.puts([
        status,
        @progress_count,
        "-",
        @example_group.parent_groups.reverse.map(&:description).join(" "),
        description,
        directive
      ].compact.join(" "))
    end

    def diagnostic(notification)
      message = notification.fully_formatted(nil)
      output.puts(prefix(message, with: "#"))
    end

    def prefix(str, with: "  ")
      str.split("\n").map { |substr| "#{with}#{substr}" }.join("\n")
    end
  end
end
