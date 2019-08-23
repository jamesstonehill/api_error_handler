Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get "/tests/runtime_error", controller: "tests"
  get "/tests/record_not_found", controller: "tests"
  get "/tests/not_implemented", controller: "tests"
  get "/tests/custom_auth_error", controller: "tests"
end
