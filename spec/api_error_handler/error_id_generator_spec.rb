require_relative "../../lib/api_error_handler/error_id_generator"

RSpec.describe ApiErrorHandler::ErrorIdGenerator do
  it "Returns the result of the proc if you git it a proc" do
    expect(described_class.run(proc { "Result!" })).to eq("Result!")
  end

  it "Returns the result of the lambda if you git it a lambda" do
    expect(described_class.run(-> { "Result!" })).to eq("Result!")
  end

  it "Returns a UUID if you give it :uuid" do
    allow(SecureRandom).to receive(:uuid).and_return("Result!")

    expect(described_class.run(:uuid)).to eq("Result!")
  end

  it "Raises an error if you give it something it doesn't recognise" do
    expect do
      described_class.run(:foo)
    end.to raise_error(ApiErrorHandler::InvalidOptionError)
  end
end
