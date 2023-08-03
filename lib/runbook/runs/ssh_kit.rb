module Runbook
  module Runs
    module SSHKit
      include Runbook::Run

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        include Runbook::Helpers::SSHKitHelper

        def runbook__entities__step(object, metadata)
          airbrussh_context = Runbook.configuration._airbrussh_context
          airbrussh_context.set_current_task_name(object.title)
          super
        end

        def runbook__statements__assert(object, metadata)
          cmd_ssh_config = find_ssh_config(object, :cmd_ssh_config)

          if metadata[:noop]
            ssh_config_output = render_ssh_config_output(cmd_ssh_config)
            metadata[:toolbox].output(ssh_config_output) unless ssh_config_output.empty?
            interval_msg = "(running every #{object.interval} second(s))"
            metadata[:toolbox].output("[NOOP] Assert: `#{object.cmd}` returns 0 #{interval_msg}")
            if object.timeout.positive? || object.attempts.positive?
              timeout_msg = object.timeout.positive? ? "#{object.timeout} second(s)" : nil
              attempts_msg = object.attempts.positive? ? "#{object.attempts} attempts" : nil
              abort_msg = "after #{[timeout_msg, attempts_msg].compact.join(' or ')}, abort..."
              metadata[:toolbox].output(abort_msg)
              if object.abort_statement
                object.abort_statement.parent = object.parent
                object.abort_statement.run(self, metadata.dup)
              end
              metadata[:toolbox].output('and exit')
            end
            return
          end

          should_abort = false
          test_args = ssh_kit_command(object.cmd, raw: object.cmd_raw)
          test_options = ssh_kit_command_options(cmd_ssh_config)

          with_ssh_config(cmd_ssh_config) do
            time = Time.now
            count = object.attempts
            until test(*test_args, test_options)
              if (count -= 1).zero?
                should_abort = true
                break
              end

              if object.timeout.positive? && Time.now - time > object.timeout
                should_abort = true
                break
              end

              sleep(object.interval)
            end
          end

          return unless should_abort

          error_msg = "Error! Assertion `#{object.cmd}` failed"
          metadata[:toolbox].error(error_msg)
          if object.abort_statement
            object.abort_statement.parent = object.parent
            object.abort_statement.run(self, metadata.dup)
          end
          raise Runbook::Runner::ExecutionError, error_msg
        end

        def runbook__statements__capture(object, metadata)
          _handle_capture(object, metadata) do |ssh_config, capture_args, capture_options|
            if ssh_config[:servers].size > 1
              warn_msg = "Warning: `capture` does not support multiple servers. Use `capture_all` instead.\n"
              metadata[:toolbox].warn(warn_msg)
            end

            result = ''
            with_ssh_config(ssh_config) do
              result = capture(*capture_args, capture_options)
            end
            result
          end
        end

        def runbook__statements__capture_all(object, metadata)
          _handle_capture(object, metadata) do |ssh_config, capture_args, capture_options|
            result = {}
            mutex = Mutex.new
            with_ssh_config(ssh_config) do
              hostname = host.hostname
              capture_result = capture(*capture_args, capture_options)
              mutex.synchronize { result[hostname] = capture_result }
            end
            result
          end
        end

        def _handle_capture(object, metadata, &block)
          ssh_config = find_ssh_config(object)

          if metadata[:noop]
            ssh_config_output = render_ssh_config_output(ssh_config)
            metadata[:toolbox].output(ssh_config_output) unless ssh_config_output.empty?
            metadata[:toolbox].output("[NOOP] Capture: `#{object.cmd}` into #{object.into}")
            return
          end

          metadata[:toolbox].output("\n") # for formatting

          capture_args = ssh_kit_command(object.cmd, raw: object.raw)
          capture_options = ssh_kit_command_options(ssh_config)
          capture_options[:strip] = object.strip
          capture_options[:verbosity] = Logger::INFO

          capture_msg = "Capturing output of `#{object.cmd}`\n\n"
          metadata[:toolbox].output(capture_msg)

          result = block.call(ssh_config, capture_args, capture_options)

          target = object.parent.dsl
          target.singleton_class.class_eval { attr_accessor object.into }
          target.send("#{object.into}=".to_sym, result)
        end

        def runbook__statements__command(object, metadata)
          ssh_config = find_ssh_config(object)

          if metadata[:noop]
            ssh_config_output = render_ssh_config_output(ssh_config)
            metadata[:toolbox].output(ssh_config_output) unless ssh_config_output.empty?
            metadata[:toolbox].output("[NOOP] Run: `#{object.cmd}`")
            return
          end

          metadata[:toolbox].output("\n") # for formatting

          execute_args = ssh_kit_command(object.cmd, raw: object.raw)
          exec_options = ssh_kit_command_options(ssh_config)

          with_ssh_config(ssh_config) do
            execute(*execute_args, exec_options)
          end
        end

        def runbook__statements__download(object, metadata)
          ssh_config = find_ssh_config(object)

          if metadata[:noop]
            ssh_config_output = render_ssh_config_output(ssh_config)
            metadata[:toolbox].output(ssh_config_output) unless ssh_config_output.empty?
            options = object.options
            to = " to #{object.to}" if object.to
            opts = " with options #{options}" unless options == {}
            noop_msg = "[NOOP] Download: #{object.from}#{to}#{opts}"
            metadata[:toolbox].output(noop_msg)
            return
          end

          metadata[:toolbox].output("\n") # for formatting

          with_ssh_config(ssh_config) do
            download!(object.from, object.to, object.options)
          end
        end

        def runbook__statements__upload(object, metadata)
          ssh_config = find_ssh_config(object)

          if metadata[:noop]
            ssh_config_output = render_ssh_config_output(ssh_config)
            metadata[:toolbox].output(ssh_config_output) unless ssh_config_output.empty?
            options = object.options
            to = " to #{object.to}" if object.to
            opts = " with options #{options}" unless options == {}
            noop_msg = "[NOOP] Upload: #{object.from}#{to}#{opts}"
            metadata[:toolbox].output(noop_msg)
            return
          end

          metadata[:toolbox].output("\n") # for formatting

          with_ssh_config(ssh_config) do
            upload!(object.from, object.to, object.options)
          end
        end
      end

      extend ClassMethods
    end
  end
end
