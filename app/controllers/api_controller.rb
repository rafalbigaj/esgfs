class ApiController < ApplicationController
  depends_on :gateway
  depends_on :status_database

  protected

  class ApiCallback
    def initialize(controller, callback)
      @controller = controller
      @callback = callback
    end

    def on_success(result)
      response_body = @callback.call(result)
      @controller.env['async.callback'].call [200, {}, [response_body]]
    rescue Exception => exception
      on_failure exception
    end

    def on_failure(exception)
      if exception.is_a?(Synapse::Command::CommandExecutionError)
        exception = exception.cause
      end

      if exception.is_a?(EsGfs::Error)
        error_message = exception.message
      else
        Rails.logger.error "[#{exception.class.name}]: #{exception.message}"
        Rails.logger.error exception.backtrace.join("\n")
        error_message = exception.message + "\n" + exception.backtrace.join("\n")
      end
      @controller.env['async.callback'].call [500, {}, [error_message]]
    end
  end

  def send_command(command_class, *args, &block)
    command = command_class.new(*args)
    gateway.send_with_callback command, ApiCallback.new(self, block)
    throw :async
  end
end