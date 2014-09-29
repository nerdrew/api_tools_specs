module APIToolsSpecs
  module RSpec
    module Helpers
      def self.extended(base)
        base.send :include, PrivateMethods
      end

      def capture_io
        require 'stringio'

        orig_stdout, orig_stderr         = $stdout, $stderr
        captured_stdout, captured_stderr = StringIO.new, StringIO.new
        $stdout, $stderr                 = captured_stdout, captured_stderr

        yield

        return captured_stdout.string, captured_stderr.string
      ensure
        $stdout = orig_stdout
        $stderr = orig_stderr
      end

      def valid_model(name = nil, &block)
        before do
          name ||= subject.class.to_s.underscore
          @valid_models ||= {}.with_indifferent_access
          @valid_models[name] = block
        end
      end

      module PrivateMethods
        def build_valid_model(*args)
          if args.size == 0 || Hash === args[0]
            name = subject.class.to_s.underscore
          else
            name = args.shift
          end
          if @valid_models && @valid_models[name]
            callable = @valid_models[name]
            instance_exec(*args, &callable)
          else
            subject.class.new *args
          end
        end

        def create_valid_model(*args)
          model = build_valid_model(*args)
          model.save!
          model
        end
      end
    end
  end
end
