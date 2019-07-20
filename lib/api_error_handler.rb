require_relative "./api_error_handler/version"
require_relative "./api_error_handler/action_controller"
Dir[File.join(__dir__, 'api_error_handler', 'serializers', "*.rb")].each { |file| require file }

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
    status_mapping = ActionDispatch::ExceptionWrapper.rescue_responses
    error_reporter = options[:error_reporter]
    serializer_options = SERIALIZER_OPTIONS.merge(
      options.slice(*SERIALIZER_OPTIONS.keys)
    )

    serializer_class = options[:serializer] || SERIALIZERS_BY_FORMAT.fetch(format)
    content_type = options[:content_type] || CONTENT_TYPE_BY_FORMAT[format]

    rescue_from StandardError do |error|
      begin
        status = status_mapping[error.class.to_s]

        error_id = nil
        error_id = options[:error_id].call(error) if options[:error_id]
        error_reporter.call(error, error_id) if error_reporter

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
