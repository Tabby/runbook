module Runbook
  module Statements
    class Assert < Runbook::Statement
      attr_reader :cmd, :cmd_ssh_config, :cmd_raw, :interval, :timeout, :attempts, :abort_statement

      def timeout_statement
        Runbook.deprecator.deprecation_warning(:timeout_statement, :abort_statement)
        @abort_statement
      end

      def initialize(
        cmd,
        cmd_ssh_config: nil,
        cmd_raw: false,
        interval: 1,
        timeout: 0,
        attempts: 0,
        abort_statement: nil,
        timeout_statement: nil
      )
        @cmd = cmd
        @cmd_ssh_config = cmd_ssh_config
        @cmd_raw = cmd_raw
        @interval = interval
        @timeout = timeout
        @attempts = attempts
        Runbook.deprecator.deprecation_warning(:timeout_statement, :abort_statement) if timeout_statement
        @abort_statement = abort_statement || timeout_statement
      end
    end
  end
end
