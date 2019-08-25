# frozen_string_literal: true

require "active_support/lazy_load_hooks"
require "action_controller"

ActiveSupport.on_load :action_controller do
  ::ActionController::Base.send :extend, ApiErrorHandler
  ::ActionController::API.send :extend, ApiErrorHandler
end
