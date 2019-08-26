# frozen_string_literal: true

require "active_support/core_ext/hash/conversions"
require_relative "./base_serializer"

module ApiErrorHandler
  module Serializers
    class Xml < BaseSerializer
      def serialize(options = {})
        body = {
          Title: title,
          Detail: @error.message,
        }

        body[:Id] = options[:error_id] if options[:error_id]
        body[:Backtrace] = @error.backtrace if options[:backtrace]

        body.to_xml(root: "Error")
      end

      def render_format
        :xml
      end
    end
  end
end
