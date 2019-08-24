class TestsController < ApplicationController
  handle_api_errors()

  def runtime_error
    raise RuntimeError, "This is a RuntimeError!"
  end

  def record_not_found
    raise ActiveRecord::RecordNotFound, "Not found!"
  end

  def not_implemented
    raise ActionController::NotImplemented, "Not Implemented!"
  end

  def custom_auth_error
    # `config.action_dispatch.rescue_responses` has been altered to map this
    # error to the :unauthorized status code in config/application.rb
    raise CustomAuthError, "Custom authentication error!"
  end
end
