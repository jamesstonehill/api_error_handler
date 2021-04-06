# frozen_string_literal: true

require "active_support/lazy_load_hooks"
require "action_controller"

ActiveSupport.on_load :action_controller do
  ::ActionController::Base.extend ApiErrorHandler
  ::ActionController::API.extend ApiErrorHandler
end
