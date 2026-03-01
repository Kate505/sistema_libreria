ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module AuthenticationHelper
  # Simula el login de un usuario creando una sesión real y seteando la cookie firmada.
  def sign_in(user)
    session_record = user.sessions.create!(
      ip_address: "127.0.0.1",
      user_agent: "Rails Testing"
    )

    # Usa el jar de cookies de ActionDispatch para firmar correctamente la cookie
    jar = ActionDispatch::Request.new(Rails.application.env_config).cookie_jar
    jar.signed[:session_id] = { value: session_record.id, httponly: true }
    cookies[:session_id] = jar[:session_id]
  end
end

class ActionDispatch::IntegrationTest
  include AuthenticationHelper
end
