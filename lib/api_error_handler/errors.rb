module ApiErrorHandler
  class Error < StandardError; end

  class InvalidOptionError < Error; end
  class MissingDependencyError < Error; end
end
