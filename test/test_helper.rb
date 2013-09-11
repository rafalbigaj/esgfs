ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'json_expressions/minitest'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  protected

  def send_command(command_class, *args)
    command = command_class.new(*args)
    gateway.send_and_wait command
  end

end

module EsGfs::Testing
	extend ActiveSupport::Concern

	included do
		include Synapse::Configuration::Dependent

		depends_on :gateway
		depends_on :es_cache
		depends_on :event_bus
		depends_on :event_store
		depends_on :file_repository

		setup do
			Synapse.container.inject_into self
		end

		teardown do |test_case|
			test_case.event_store.clear
			test_case.es_cache.clear
		end

		if self < ActionController::TestCase
			class_eval do
				def process(*args)
					@controller.env['async.callback'] = Proc.new do |response|
            @response = ActionController::TestResponse.new(*response)
          end
					catch(:async) { super }
				end
			end
		end
	end

end

Rack::MockSession.class_eval do
	private

	def request_with_async_callback(uri, env)
		env['async.callback'] = Proc.new do |response|
      @last_response = Rack::MockResponse.new(*response)
    end
		catch(:async) { request_without_async_callback(uri, env) }
	end

	alias_method_chain :request, :async_callback
end