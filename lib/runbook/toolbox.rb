module Runbook
  class Toolbox
    attr_reader :prompt

    def initialize
      @prompt = TTY::Prompt.new
    end

    def ask(msg, default: nil, echo: true)
      prompt.ask(msg, default:, echo:)
    end

    def expand(msg, choices)
      prompt.expand(msg, choices)
    end

    def yes?(msg)
      prompt.yes?(msg)
    end

    def output(msg)
      prompt.say(msg)
    end

    def warn(msg)
      prompt.warn(msg)
    end

    def error(msg)
      prompt.error(msg)
    end

    public :exit
  end
end
