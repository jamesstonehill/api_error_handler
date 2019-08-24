# ApiErrorHandler
[![Build Status](https://travis-ci.org/jamesstonehill/api_error_handler.svg?branch=master)](https://travis-ci.org/jamesstonehill/api_error_handler)

Are your API error responses not all that you want them to be? If so, you've
found the right gem! `api_error_handler` handles all aspects of returning
informative, spec-compliant responses to clients when your application
encounters an error in the course of processing a response.

This "handling" includes:
- __Error serialization__: each response will include a response body that
    gives some information on the type of error that your application
    encountered. See the [Responses Body Options](#response-body-options)
    section for details and configuration options.
- __Status code setting__: `api_error_handler` will set the HTTP status code of
    the response based on the type of error that is raised. For example, when an
    `ActiveRecord::RecordNotFound` error is raised, it will set the response
    status to 404. See the [HTTP Status Mapping](#http-status-mapping) section
    for details and configuration options.
- __Error reporting__: If you use a 3rd party bug tracking
    tool like Honeybadger or Sentry, `api_error_handler` will notify this
    service of the error for you so you don't have to!
- __Content type setting__: `api_error_handler` will set the content type of the
    response based on the format of response body.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'api_error_handler'
```

And then execute:

    $ bundle install

## Usage

To get started, all you need to do is invoke `handle_api_errors` inside your
controller like so:

```ruby
class MyController < ActionController::API
  handle_api_errors()

  def index
    raise "Something is very very wrong!"
  end
end
```

Now when you go to `MyController#index`, your API will return the following
response:

```json
HTTP/1.1 500 Internal Server Error
Content-Type: application/json

{
  "error": {
    "title":"Internal Server Error",
    "detail":"Something is very very wrong!"
  }
}
```

### Error handling options

`handle_api_errors` implements a bunch of (hopefully) sensible defaults so that
all you need to do is invoke `handle_api_errors()` in your controller to get
useful error handling! However, in all likelihood you'll want to override some
of these options. This section gives details on the various options available
for configuring the `api_error_handler`.

#### Response Body Options
By default, `handle_api_errors` picks the `:json` format for serializing errors.
However, this gem comes with a number of other formats for serializing your
errors.

##### JSON (the default)
```ruby
  handle_api_errors(format: :json)
  # Or
  handle_api_errors()
```

```json
HTTP/1.1 500 Internal Server Error
Content-Type: application/json

{
  "error": {
    "title":"Internal Server Error",
    "detail":"Something is very very wrong!"
  }
}
```

##### JSON:API
If your API follows the `JSON:API` spec, you'll want to use the `:json_api`
format option.

```ruby
  handle_api_errors(format: :json_api)
```

Responses with this format will follow the `JSON:API` [specification for error
objects](https://jsonapi.org/format/#error-objects). This will look something
like this:

```json
HTTP/1.1 500 Internal Server Error
Content-Type: application/vnd.api+json

{
  "errors": [
    {
      "status":"500",
      "title":"Internal Server Error",
      "detail":"Something is very very wrong!"
    }
  ]
}
```

##### XML
```ruby
  handle_api_errors(format: :xml)
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Error>
  <Title>Internal Server Error</title>
  <Detail>Something is very very wrong!</detail>
</Error>
```

##### Custom Error Responses
If none of the out-of-the-box options suit you then you can pass in your own
error serializer like so:

```ruby
  handle_api_errors(serializer: MyCustomErrorSerializer)
```

The custom serializer must implement two instance methods, `serialize` and
`render_format`. The `serialize` method should return the body of the response
you want to render. The `render_format` should be the format that you want to
render the response in (e.g `:json`, `:xml`, `:plain`), which will be passed to
Rails' `render` method.

It is recommended you inherit your serializer from
`ApiErrorHandler::Serializers::BaseSerializer` to gain some helpful instance
methods and defaults.

```ruby
class MyCustomErrorSerializer < ApiErrorHandler::Serializers::BaseSerializer
  def serialize(serializer_options)
    # The `title` and `status_code` come from the BaseSerializer.
    "Error! Title: #{title} Status Code: #{status_code}"
  end

  def render_format
    :plain
  end
end
```
##### Backtraces
If you want to include the error's backtrace in the response body:

```ruby
  handle_api_errors(backtrace: true)
```

```json
{
  "error": {
    "title":"Internal Server Error",
    "detail":"Something is very very wrong!",
    "backtrace": [
      # The backtrace
    ]
  }
}
```

### HTTP Status Mapping

Most of the time, you'll want to set the HTTP status code based on the type of
error being raised. To determine which errors map to which status codes,
`api_error_handler` uses `ActionDispatch::ExceptionWrapper.rescue_responses`. If
you're using Rails with ActiveRecord, by default this includes:

```ruby
{
  "ActionController::RoutingError"               => :not_found,
  "AbstractController::ActionNotFound"           => :not_found,
  "ActionController::MethodNotAllowed"           => :method_not_allowed,
  "ActionController::UnknownHttpMethod"          => :method_not_allowed,
  "ActionController::NotImplemented"             => :not_implemented,
  "ActionController::UnknownFormat"              => :not_acceptable,
  "Mime::Type::InvalidMimeType"                  => :not_acceptable,
  "ActionController::MissingExactTemplate"       => :not_acceptable,
  "ActionController::InvalidAuthenticityToken"   => :unprocessable_entity,
  "ActionController::InvalidCrossOriginRequest"  => :unprocessable_entity,
  "ActionDispatch::Http::Parameters::ParseError" => :bad_request,
  "ActionController::BadRequest"                 => :bad_request,
  "ActionController::ParameterMissing"           => :bad_request,
  "Rack::QueryParser::ParameterTypeError"        => :bad_request,
  "Rack::QueryParser::InvalidParameterError"     => :bad_request
  "ActiveRecord::RecordNotFound"                 => :not_found,
  "ActiveRecord::StaleObjectError"               => :conflict,
  "ActiveRecord::RecordInvalid"                  => :unprocessable_entity,
  "ActiveRecord::RecordNotSaved"                 => :unprocessable_entity
}
```
- https://guides.rubyonrails.org/configuring.html#configuring-action-dispatch

You can add to this mapping on an application level by doing the following:
```ruby
config.action_dispatch.rescue_responses.merge!(
  "AuthenticationError" => :unauthorized
)
```

Now when an you raise an `AuthenticationError` in one of your actions, the
status code of the response will be 401.

### Error IDs
Sometimes it's helpful to include IDs with your error responses so that you can
correlate a specific error with a record in your logs or bug tracking software.
For this you can use the `error_id` option.

You can either use the UUID error strategy
```ruby
handle_api_errors(error_id: :uuid)
```

Or pass a Proc if you need to do something custom.
```ruby
handle_api_errors(error_id: Proc.new { |error| SecureRandom.uuid })
```

These will result in:
```json
{
  "error": {
    "title": "Internal Server Error",
    "detail": "Something is very very wrong!",
    "id": "4ab520f2-ae33-4539-9371-ea21aada5582"
  }
}
```

### Error Reporting
If you use an external error tracking software like Sentry or Honeybadger, you'll
want to report all errors to that service.

#### Out of the Box Error Reporting
There are a few supported error reporter options that you can select.

##### Raven/Sentry
```ruby
handle_api_errors(error_reporter: :raven)
# Or
handle_api_errors(error_reporter: :sentry)
```

##### Honeybadger
```ruby
handle_api_errors(error_reporter: :honeybadger)
```

__NOTE:__ If you use the `:error_id` option, the error error reporter will tag
the exception with the error ID when reporting the error.

#### Custom Reporting
If none of the out of the box options work for you, you can pass in a proc which
will receive the error and the error_id as arguments.

```ruby
handle_api_errors(
  error_reporter: Proc.new do |error, error_id|
    # Do something with the `error` here.
  end
)
```

### Setting Content Type
The api_error_handler will set the content type of your error based on the
`format` option you pick. However, you can override this by setting the
`content_type` option if you wish.

```ruby
handle_api_errors(
  format: :json,
  content_type: 'application/vnd.api+json'
)
```

```json
HTTP/1.1 500 Internal Server Error
Content-Type: application/vnd.api+json

{
  "error": {
    "title":"Internal Server Error",
    "detail":"Something is very very wrong!"
  }
}
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
