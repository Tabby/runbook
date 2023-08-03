module Runbook
  module Hooks
    def hooks
      @hooks ||= []
    end

    def register_hook(name, type, klass, before: nil, &block)
      hook = {
        name:,
        type:,
        klass:,
        block:
      }

      if before
        hooks.insert(_hook_index(before), hook)
      else
        hooks << hook
      end
    end

    def hooks_for(type, klass)
      hooks.select do |hook|
        hook[:type] == type && klass <= hook[:klass]
      end
    end

    def _hook_index(hook_name)
      hooks.index { |hook| hook[:name] == hook_name } || -1
    end

    module Invoker
      def invoke_with_hooks(executor, object, *args, &block)
        skip_before = skip_around = skip_after = false
        if executor <= Runbook::Run && executor.should_skip?(args[0])
          skip_before = skip_around = if executor.start_at_is_substep?(object, args[0])
                                        true
                                      else
                                        skip_after = true
                                      end
        end

        _execute_before_hooks(executor, object, *args) unless skip_before

        if skip_around
          block.call
        else
          _execute_around_hooks(executor, object, *args, &block)
        end

        return if skip_after

        _execute_after_hooks(executor, object, *args)
      end

      def _execute_before_hooks(executor, object, *)
        executor.hooks_for(:before, object.class).each do |hook|
          executor.instance_exec(object, *, &hook[:block])
        end
      end

      # rubocop:disable Lint/ShadowingOuterLocalVariable
      # rubocop:disable Lint/UnusedBlockArgument
      def _execute_around_hooks(executor, object, *)
        executor.hooks_for(:around, object.class).reverse.reduce(
          lambda { |object, *|
            yield
          }
        ) do |inner_method, hook|
          lambda { |object, *|
            inner_block = proc do |object, *|
              inner_method.call(object, *)
            end
            executor.instance_exec(object, *, inner_block, &hook[:block])
          }
        end.call(object, *)
      end
      # rubocop:enable Lint/UnusedBlockArgument
      # rubocop:enable Lint/ShadowingOuterLocalVariable

      def _execute_after_hooks(executor, object, *)
        executor.hooks_for(:after, object.class).each do |hook|
          executor.instance_exec(object, *, &hook[:block])
        end
      end
    end
  end
end
