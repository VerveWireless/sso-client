require 'rails'
require 'active_support/core_ext/numeric/time'
require 'active_support/dependencies'
require 'active_resource'
require 'action_controller'
require 'rails_warden'

module Bsm
  module Sso
    module Client
      UnauthorizedAccess = Class.new(ActionController::ActionControllerError)

      autoload :AbstractResource, 'bsm/sso/client/abstract_resource'
      autoload :User, 'bsm/sso/client/user'
      autoload :UserMethods, 'bsm/sso/client/user_methods'
      autoload :UrlHelpers, 'bsm/sso/client/url_helpers'
      autoload :FailureApp, 'bsm/sso/client/failure_app'
      autoload :Cached, 'bsm/sso/client/cached'

      mattr_accessor :secret
      @@secret = nil

      mattr_accessor :expire_after
      @@expire_after = 2.hours

      mattr_writer :user_class
      @@user_class = nil

      mattr_accessor :warden_configuration
      @@warden_configuration = nil

      class << self

        delegate :site=, :site, :to => :"Bsm::Sso::Client::AbstractResource"

        def user_class
          @@user_class || Bsm::Sso::Client::User
        end

        # Default message verifier
        def verifier
          raise "Please configure a secret! Example: Bsm::Sso::Client.secret = '...'" unless secret.present?
          @verifier ||= ActiveSupport::MessageVerifier.new(secret)
        end

        # Configure the SSO. Example:
        #
        #   # config/initializers/sso.rb
        #   Bsm::Sso::Client.configure do |c|
        #     c.site = "https://sso.example.com"
        #     c.secret = "m4GHRWxvXiL3ZSR8adShpqNWXmepkqeyUqRfpB8F"
        #   end
        def configure(&block)
          tap(&block)
        end

        # Warden configuration. Example:
        #
        #   # config/initializers/sso.rb
        #   Bsm::Sso::Client.configure do |c|
        #     c.warden do |manager|
        #       manager.default_strategies << :my_strategy
        #     end
        #   end
        def warden(&block)
          @@warden_configuration = block
        end

        # Raises an UnauthorizedAccess exception
        def forbidden!(request, message = nil)
          message ||= "You are not permitted to access the resource in #{request.path}"
          raise UnauthorizedAccess, message
        end

      end
    end
  end
end

require 'bsm/sso/client/railtie'
require 'bsm/sso/client/warden_ext'
require 'bsm/sso/client/strategies'
