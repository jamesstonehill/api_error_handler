# frozen_string_literal: true

require_relative "./base_serializer"

module ApiErrorHandler
  module Serializers
    class Json < BaseSerializer
      # There is no official spec that governs this error response format so
      # this serializer is just trying to impliment a simple response with
      # sensible defaults.
      #
      # I borrowed heavily from Facebook's error response format since it seems
      # to be a reasonable approach for a simple light-weight error response.

      def serialize(options = {})
        body = {
          error: {
            title: title,
            detail: @error.message,
          }
        }

        body[:error][:id] = options[:error_id] if options[:error_id]
        body[:error][:backtrace] = @error.backtrace if options[:backtrace]

        body.to_json
      end

      def render_format
        :json
      end
    end
  end
end
