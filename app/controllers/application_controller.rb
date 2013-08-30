class ApplicationController < ActionController::Base
  protect_from_forgery
	include Synapse::Configuration::Dependent

	before_filter do |controller|
		Synapse.container.inject_into controller
	end
end
