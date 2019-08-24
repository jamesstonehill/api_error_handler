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
      else
        raise(InvalidOptionError, "`#{@strategy}` is an invalid argument for the `:error_id` option.")
      end
    end
  end
end
