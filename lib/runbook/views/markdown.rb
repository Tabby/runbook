module Runbook
  module Views
    module Markdown
      include Runbook::View
      extend Runbook::Helpers::FormatHelper
      extend Runbook::Helpers::SSHKitHelper

      def self.runbook__entities__book(object, output, _metadata)
        output << "# #{object.title}\n\n"
      end

      def self.runbook__entities__section(object, output, metadata)
        heading = '#' * metadata[:depth]
        output << "#{heading} #{metadata[:index] + 1}. #{object.title}\n\n"
      end

      def self.runbook__entities__setup(object, output, _metadata)
        output << "[] #{object.title}\n\n"

        ssh_config = find_ssh_config(object)
        ssh_config_output = render_ssh_config_output(ssh_config)
        output << "#{ssh_config_output}\n" unless ssh_config_output.empty?
      end

      def self.runbook__entities__step(object, output, metadata)
        output << "#{metadata[:index] + 1}. [] #{object.title}\n\n"

        ssh_config = find_ssh_config(object)
        ssh_config_output = render_ssh_config_output(ssh_config)
        output << "#{ssh_config_output}\n" unless ssh_config_output.empty?
      end

      def self.runbook__statements__ask(object, output, _metadata)
        default_msg = object.default ? " (default: #{object.default})" : ''
        output << "   #{object.prompt} into `#{object.into}`#{default_msg}\n\n"
      end

      def self.runbook__statements__assert(object, output, metadata)
        output << "   run: `#{object.cmd}` every #{object.interval} seconds until it returns 0\n\n"
        return unless object.timeout.positive? || object.attempts.positive?

        timeout_msg = object.timeout.positive? ? "#{object.timeout} second(s)" : nil
        attempts_msg = object.attempts.positive? ? "#{object.attempts} attempts" : nil
        abort_msg = "after #{[timeout_msg, attempts_msg].compact.join(' or ')}, abort..."
        output << "   #{abort_msg}\n\n"
        object.abort_statement&.render(self, output, metadata.dup)
        output << "   and exit\n\n"
      end

      def self.runbook__statements__capture(object, output, _metadata)
        output << "   capture: `#{object.cmd}` into `#{object.into}`\n\n"
      end

      def self.runbook__statements__capture_all(object, output, _metadata)
        output << "   capture_all: `#{object.cmd}` into `#{object.into}`\n\n"
      end

      def self.runbook__statements__command(object, output, _metadata)
        output << "   run: `#{object.cmd}`\n\n"
      end

      def self.runbook__statements__confirm(object, output, _metadata)
        output << "   confirm: #{object.prompt}\n\n"
      end

      def self.runbook__statements__description(object, output, _metadata)
        output << "#{object.msg}\n"
      end

      def self.runbook__statements__download(object, output, _metadata)
        options = object.options
        to = " to #{object.to}" if object.to
        opts = " with options #{options}" unless options == {}
        output << "   download: #{object.from}#{to}#{opts}\n\n"
      end

      def self.runbook__statements__layout(object, output, _metadata)
        output << "layout:\n"
        output << "#{object.structure.inspect}\n\n"
      end

      def self.runbook__statements__note(object, output, _metadata)
        output << "   #{object.msg}\n\n"
      end

      def self.runbook__statements__notice(object, output, _metadata)
        output << "   **#{object.msg}**\n\n"
      end

      def self.runbook__statements__ruby_command(object, output, _metadata)
        output << "   run:\n"
        output << "   ```ruby\n"
        begin
          output << "#{deindent(object.block.source, padding: 3)}\n"
        rescue ::MethodSource::SourceNotFoundError => _e
          output << "   Unable to retrieve source code\n"
        end
        output << "   ```\n\n"
      end

      def self.runbook__statements__tmux_command(object, output, _metadata)
        output << "   run: `#{object.cmd}` in pane #{object.pane}\n\n"
      end

      def self.runbook__statements__upload(object, output, _metadata)
        options = object.options
        to = " to #{object.to}" if object.to
        opts = " with options #{options}" unless options == {}
        output << "   upload: #{object.from}#{to}#{opts}\n\n"
      end

      def self.runbook__statements__wait(object, output, _metadata)
        output << "   wait: #{object.time} seconds\n\n"
      end
    end
  end
end
