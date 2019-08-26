# frozen_string_literal: true

require "securerandom"
require_relative "./errors"

module ApiErrorHandler
  class ErrorIdGenerator
    def self.run(error_id_option)
      if error_id_option.instance_of?(Proc)
        error_id_option.call
      elsif error_id_option == :uuid
        SecureRandom.uuid
      elsif error_id_option.nil?
        nil
      else
        raise(
          InvalidOptionError,
          "Unable to handle `#{error_id_option}` as argument for the `:error_id` option."
        )
      end
    end
  end
end
