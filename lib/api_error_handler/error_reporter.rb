# frozen_string_literal: true

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
        raise_dependency_error(missing_constant: "Honeybadger") unless defined?(Honeybadger)

        context = error_id ? { error_id: error_id } : {}
        Honeybadger.notify(error, context: context)
      elsif @strategy == :raven || @strategy == :sentry
        raise_dependency_error(missing_constant: "Raven") unless defined?(Raven)

        extra = error_id ? { error_id: error_id } : {}
        Raven.capture_exception(error, extra: extra)
      else
        raise(
          InvalidOptionError,
          "`#{@strategy.inspect}` is an invalid argument for the `:error_id` option."
        )
      end
    end

    private

    def raise_dependency_error(missing_constant:)
      raise MissingDependencyError, <<~MESSAGE
        You selected the #{@strategy.inspect} error reporter option but the
        #{missing_constant} constant is not defined. If you wish to use this
        error reporting option you must have the #{@strategy} client gem
        installed.
      MESSAGE
    end
  end
end
