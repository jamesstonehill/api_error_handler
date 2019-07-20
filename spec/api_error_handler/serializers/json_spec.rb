require 'json'
require_relative "../../../lib/api_error_handler/serializers/json"

RSpec.describe ApiErrorHandler::Serializers::Json do
  describe "#serialize" do
    it "renders the error in a JSON format" do
      error = RuntimeError.new("RuntimeError message!")
      status = :not_found

      serializer = described_class.new(error, status)

      response = JSON.parse(serializer.serialize, symbolize_names: true)

      expect(response).to eq(
        error: { title: "Not Found", detail: "RuntimeError message!" }
      )
    end

    it "includes the error id if one is provided" do
      error = RuntimeError.new("RuntimeError message!")
      status = :not_found

      serializer = described_class.new(error, status)
      response = JSON.parse(serializer.serialize(error_id: "123"), symbolize_names: true)

      expect(response.dig(:error, :id)).to eq("123")
    end

    it "includes the backtrace if the backtrace option is true" do
      begin
        raise "some error"
      rescue => e
        error = e
      end

      status = :not_found

      serializer = described_class.new(error, status)
      response = JSON.parse(serializer.serialize(backtrace: true), symbolize_names: true)

      expect(response.dig(:error, :backtrace)).to eq(error.backtrace)
    end
  end
end
