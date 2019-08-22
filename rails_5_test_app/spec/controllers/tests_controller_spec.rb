require 'rails_helper'

RSpec.describe TestsController, type: :controller do
  let(:json_body) { JSON.parse(response.body, symbolize_names: true) }

  it "re-raises the error when something goes wrong with the rendering process" do
    described_class.send(:handle_api_errors)
    allow_any_instance_of(TestsController)
      .to receive(:render)
      .and_raise(StandardError, "This is not the error that should be raised")

    expect(Rails.logger).to receive(:error)
    expect { get :runtime_error }.to raise_error(RuntimeError, "This is a RuntimeError!")
  end

  context "with defaults" do
    before do
      described_class.send(:handle_api_errors)
    end

    it "renders the error in JSON format" do
      get :runtime_error

      expect(json_body).to eq(
        error: {
          title: "Internal Server Error",
          detail: "This is a RuntimeError!"
        }
      )
    end

    it "sets the status code based on the ActionDispatch::ExceptionWrapper.rescue_responses mapping" do
      get :runtime_error
      expect(response.code).to eq("500")

      get :record_not_found
      expect(response.code).to eq("404")

      get :not_implemented
      expect(response.code).to eq("501")

      get :custom_auth_error
      expect(response.code).to eq("401")
    end

    it "sets the content type to application/json" do
      get :runtime_error
      expect(response.content_type).to start_with("application/json")
    end
  end

  context "when the format is set to :json_api" do
    before do
      described_class.send(:handle_api_errors, format: :json_api)
    end

    it "sets the content_type to application/vnd.api+json" do
      get :runtime_error

      expect(response.content_type).to start_with("application/vnd.api+json")
    end

    it "can render errros in JSON:API format" do
      get :runtime_error

      expect(json_body).to eq(
        errors: [
          {
            title: "Internal Server Error",
            detail: "This is a RuntimeError!",
            status: "500"
          }
        ]
      )
    end
  end

  context "when using a custom serializer" do
    let(:custom_serializer) do
      Class.new(ApiErrorHandler::Serializers::BaseSerializer) do
        def serialize(serializer_options)
          "Error! Title: #{title} Status Code: #{status_code}"
        end

        def render_format
          :plain
        end
      end
    end

    before do
      described_class.send(:handle_api_errors, serializer: custom_serializer)
    end

    it "renders the body using the custom serializer's serialize method" do
      get :runtime_error

      expect(response.body).to eq("Error! Title: Internal Server Error Status Code: 500")
      expect(response.content_type).to start_with("text/plain")
    end
  end

  context "when you provide the error_reporter option" do
    it "reports errors" do
      error_reporter = double(report: true)
      described_class.send(
        :handle_api_errors,
        error_reporter: Proc.new { |error| error_reporter.report(error) }
      )

      expect(error_reporter).to receive(:report).with(instance_of(RuntimeError))

      get :runtime_error
    end
  end

  context "when you also provide both the error_reporter and error_id options" do
    it "reports the error with the error id" do
      error_reporter = double(report: true)
      described_class.send(
        :handle_api_errors,
        error_id: Proc.new { "error_id" },
        error_reporter: Proc.new { |error, error_id| error_reporter.report(error, error_id) }
      )

      expect(error_reporter)
        .to receive(:report)
        .with(instance_of(RuntimeError), "error_id")

      get :runtime_error
    end
  end

  context "when you include the backtrace option" do
    it "displays the error's backtrace" do
      described_class.send(:handle_api_errors, backtrace: true)

      get :runtime_error

      expect(json_body.dig(:error, :backtrace)).to be_present
    end
  end
end
