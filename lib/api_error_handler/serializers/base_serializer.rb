require 'rack/utils'

module ApiErrorHandler
  module Serializers
    class BaseSerializer
      DEFAULT_STATUS_CODE = "500".freeze

      def initialize(error, status)
        @error = error
        @status = status
      end

      def status_code
        Rack::Utils::SYMBOL_TO_STATUS_CODE.fetch(@status, DEFAULT_STATUS_CODE).to_s
      end

      def title
        Rack::Utils::HTTP_STATUS_CODES.fetch(status_code.to_i)
      end
    end
  end
end
