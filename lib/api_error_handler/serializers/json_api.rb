# frozen_string_literal: true

require_relative "./base_serializer"

module ApiErrorHandler
  module Serializers
    class JsonApi < BaseSerializer
      def serialize(options = {})
        body = {
          errors: [
            {
              status: status_code,
              title: title,
              detail: @error.message,
            }
          ]
        }

        body[:errors].first[:id] = options[:error_id] if options[:error_id]
        body[:errors].first[:meta] = { backtrace: @error.backtrace } if options[:backtrace]

        body.to_json
      end

      def render_format
        :json
      end
    end
  end
end
