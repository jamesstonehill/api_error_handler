# frozen_string_literal: true

require_relative "../../lib/api_error_handler/error_reporter"

RSpec.describe ApiErrorHandler::ErrorReporter do
  let(:error) { RuntimeError.new("Error message") }

  it "Raises an InvalidOptionError if you provide an bad option" do
    reporter = described_class.new(:asdf)

    expect do
      reporter.report(error)
    end.to raise_error(ApiErrorHandler::InvalidOptionError)
  end

  context "using the `nil` strategy" do
    let(:reporter) { described_class.new(nil) }

    it "Does nothing if the strategy is `nil`" do
      reporter.report(error)
    end
  end

  context "using a Proc strategy" do
    it "Calls the Proc with the error and error_id" do
      strategy = proc do |e, error_id|
        expect(e).to eq(error)
        expect(error_id).to eq("123")
      end

      reporter = described_class.new(strategy)

      reporter.report(error, error_id: "123")
    end
  end

  context "using the :honeybadger strategy" do
    let(:reporter) { described_class.new(:honeybadger) }

    it "Raises an error if the Honeybadger constant is not defined" do
      expect { reporter.report(error) }.to raise_error(ApiErrorHandler::MissingDependencyError)
    end

    it "Reports to Honeybadger with an error id" do
      stub_const("Honeybadger", double)
      expect(Honeybadger).to receive(:notify).with(error, context: { error_id: "456" })

      reporter.report(error, error_id: "456")
    end

    it "Reports to Honeybadger without an error id" do
      stub_const("Honeybadger", double)
      expect(Honeybadger).to receive(:notify).with(error, context: {})

      reporter.report(error)
    end
  end

  context "using the :raven/:sentry strategy" do
    let(:reporter) { described_class.new(:sentry) }

    it "Raises an error if the Raven constant is not defined" do
      expect { reporter.report(error) }.to raise_error(ApiErrorHandler::MissingDependencyError)
    end

    it "Reports to Honeybadger with an error id" do
      stub_const("Raven", double)
      expect(Raven).to receive(:capture_exception).with(error, extra: { error_id: "456" })

      reporter.report(error, error_id: "456")
    end

    it "Reports to Honeybadger without an error id" do
      stub_const("Raven", double)
      expect(Raven).to receive(:capture_exception).with(error, extra: {})

      reporter.report(error)
    end
  end
end
