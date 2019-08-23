module ApiErrorHandler
  class Error < StandardError; end

  class InvalidOptionError < Error; end
end
