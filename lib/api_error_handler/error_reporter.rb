require "logger"
require_relative "./errors"

module ApiErrorHandler
  class ErrorReporter
    def initialize(strategy)
      @strategy = strategy
    end

    def report(error, error_id: nil)
      if @strategy.nil?
        true
      elsif @strategy.instance_of?(Proc)
        @strategy.call(error, error_id)
      elsif @strategy == :honeybadger
        unless defined?(Honeybadger)
          raise MissingDependencyError, "You selected the :honeybadger error reporter option but the Honeybadger constant is not defined. If you wish to use this error reporting option you must have the Honeybadger gem installed."
        end

        context = error_id ? { error_id: error_id } : {}
        Honeybadger.notify(error, context: context)
      else
        raise(InvalidOptionError, "`#{@strategy.inspect}` is an invalid argument for the `:error_id` option.")
      end
    end
  end
end
