# frozen_string_literal: true

require_relative "../../../lib/api_error_handler/serializers/xml"

RSpec.describe ApiErrorHandler::Serializers::Xml do
  describe "#serialize" do
    it "renders the error in a xml format" do
      error = RuntimeError.new("RuntimeError message!")

      serializer = described_class.new(error, :not_found)

      expect(serializer.serialize).to eq(<<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <Error>
          <Title>Not Found</Title>
          <Detail>RuntimeError message!</Detail>
        </Error>
      XML
      )
    end

    it "includes the error ID if the error_id option is present" do
      error = RuntimeError.new("RuntimeError message!")

      serializer = described_class.new(error, :not_found)
      response = Hash.from_xml(serializer.serialize(error_id: "567"))

      expect(response.dig("Error", "Id")).to eq("567")
    end

    it "includes the backtrace if the backtrace option is true" do
      begin
        raise "some error"
      rescue => e
        error = e
      end

      serializer = described_class.new(error, :not_found)
      response = Hash.from_xml(serializer.serialize(backtrace: true))

      expect(response.dig("Error", "Backtrace")).to eq(error.backtrace)
    end
  end
end
