require_relative "../../lib/api_error_handler/error_reporter"

RSpec.describe ApiErrorHandler::ErrorReporter do
  it "Raises an InvalidOptionError if you provide an bad option" do
    reporter = described_class.new(:asdf)

    expect do
      reporter.report(RuntimeError.new)
    end.to raise_error(ApiErrorHandler::InvalidOptionError)
  end

  it "Does nothing if the strategy is `nil`" do
    reporter = described_class.new(nil)

    reporter.report(RuntimeError.new('Foo'))
  end

  it "Calls the Proc with the error and error_id if you pass in a proc as the strategy" do
    strategy = proc do |error, error_id|
      expect(error).to be_instance_of(RuntimeError)
      expect(error_id).to eq("123")
    end

    reporter = described_class.new(strategy)

    reporter.report(RuntimeError.new, error_id: "123")
  end
end
