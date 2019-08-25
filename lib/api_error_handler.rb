# frozen_string_literal: true

require_relative "./api_error_handler/version"
require_relative "./api_error_handler/action_controller"
require_relative "./api_error_handler/error_id_generator"
require_relative "./api_error_handler/error_reporter"
Dir[File.join(__dir__, "api_error_handler", "serializers", "*.rb")].each do |file|
  require file
end

module ApiErrorHandler
  SERIALIZERS_BY_FORMAT = {
    json: Serializers::Json,
    json_api: Serializers::JsonApi,
    xml: Serializers::Xml,
  }.freeze

  SERIALIZER_OPTIONS = {
    backtrace: false,
  }.freeze

  CONTENT_TYPE_BY_FORMAT = {
    json_api: "application/vnd.api+json"
  }.freeze

  def handle_api_errors(options = {})
    format = options.fetch(:format, :json)
    error_reporter = ErrorReporter.new(options[:error_reporter])
    serializer_options = SERIALIZER_OPTIONS.merge(
      options.slice(*SERIALIZER_OPTIONS.keys)
    )

    serializer_class = options[:serializer] || SERIALIZERS_BY_FORMAT.fetch(format)
    content_type = options[:content_type] || CONTENT_TYPE_BY_FORMAT[format]
    rescue_from StandardError do |error|
      begin
        status = ActionDispatch::ExceptionWrapper.rescue_responses[error.class.to_s]

        error_id = ErrorIdGenerator.run(options[:error_id])
        error_reporter.report(error, error_id: error_id)

        serializer = serializer_class.new(error, status)
        response_body = serializer.serialize(
          serializer_options.merge(error_id: error_id)
        )

        render(
          serializer.render_format => response_body,
          content_type: content_type,
          status: status
        )
      rescue
        raise error
      end
    end
  end
end
