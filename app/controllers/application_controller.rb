class ApplicationController < ActionController::Base
  include Synapse::Configuration::Dependent

  protect_from_forgery

	before_filter do |controller|
		Synapse.container.inject_into controller
	end
end
