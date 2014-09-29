module APIToolsSpecs
  module AnonymousModel
    class ConnectionHolder < ActiveRecord::Base
      self.abstract_class = true
      establish_connection(adapter: 'sqlite3', database: ':memory:', anonymous_model: true)
    end

    def build_model(name, options={}, &block)
      klass_name  = name.to_s.camelize

      superclass = options.delete(:superclass) || ConnectionHolder
      contained   = options.delete(:contained)  || Object

      include PrivateMethods

      before(:all) do
        klass = Class.new(superclass || @connection_holder)
        contained.const_set(klass_name, klass)

        klass.module_eval do
          cattr_accessor :anonymous_model_log
          self.anonymous_model_log = ''
          self.logger = Logger.new(StringIO.new(anonymous_model_log))
        end

        klass.connection.create_table(klass.table_name, options.reverse_merge(force: true))

        model_eval(klass, &block)
      end

      after(:each) { delete_instances klass_name, contained }
      after(:all) do
        delete_model klass_name, contained
        ActiveSupport::Dependencies.clear
      end
      nil
    end

    module PrivateMethods
      def model_eval(klass, &block)
        class << klass
          def method_missing_with_columns(sym, *args, &block)
            connection.change_table(table_name) do |t|
              t.send(sym, *args)
            end
          end

          alias_method_chain :method_missing, :columns
        end

        klass.class_eval(&block) if block_given?

        class << klass
          remove_method :method_missing
          alias_method :method_missing, :method_missing_without_columns
        end
        nil
      end

      def delete_model(name, contained)
        klass_name  = name.to_s.camelize
        old_klass = contained.const_get(klass_name)
        old_klass.connection.drop_table(old_klass.table_name)
        old_klass.reset_column_information
        contained.send(:remove_const, klass_name)

        nil
      rescue NameError => e
        nil
      end

      def delete_instances(name, contained)
        klass_name = name.to_s.camelize
        old_klass = contained.const_get(klass_name)
        old_klass.destroy_all

        nil
      rescue NameError
        nil
      end
    end
  end
end
