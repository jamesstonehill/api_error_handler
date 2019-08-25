# frozen_string_literal: true

require "json"
require_relative "../../../lib/api_error_handler/serializers/json_api"

RSpec.describe ApiErrorHandler::Serializers::JsonApi do
  it "has a render format of :json" do
    error = RuntimeError.new("RuntimeError message!")
    status = :not_found

    serializer = described_class.new(error, status)

    expect(serializer.render_format).to eq(:json)
  end

  describe "#serialize" do
    it "renders the error in JSON:API format" do
      error = RuntimeError.new("RuntimeError message!")
      status = :not_found

      serializer = described_class.new(error, status)

      response = JSON.parse(serializer.serialize, symbolize_names: true)

      expect(response).to eq(
        errors: [
          { title: "Not Found", detail: "RuntimeError message!", status: "404" }
        ]
      )
    end

    it "includes the backtrace if the backtrace option is true" do
      error = nil

      begin
        raise "some error"
      rescue => e
        error = e
      end

      status = :not_found

      serializer = described_class.new(error, status)
      response = JSON.parse(serializer.serialize(backtrace: true), symbolize_names: true)

      expect(response[:errors].first.dig(:meta, :backtrace)).to eq(error.backtrace)
    end
  end
end
