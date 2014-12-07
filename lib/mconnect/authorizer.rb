require 'mconnect/helpers'

module Mconnect
  class Authorizer
    include Helpers

    attr_writer :verifier

    def initialize
      oauth_options  = load_yaml "#{Dir.home}/.mconnect/config.yml"
      client_options = { :site => oauth_options['site'],
                         :authorize_path => '/oauth/authorize',
                         :request_token_path => '/oauth/request_token',
                         :access_token_path => '/oauth/access_token' }

      @client = OAuth::Consumer.new(
                  oauth_options['consumer_key'],
                  oauth_options['consumer_secret'],
                  client_options
                )
    end

    def access_token
      access_token = load_yaml "#{Dir.home}/.mconnect/authorization.yml"
      OAuth::AccessToken.new(@client, access_token.token, access_token.secret)
    end

    def request_token
      @request_token ||= @client.get_request_token
    end

    def authorize_url
      request_token.authorize_url
    end

    def authorization
      request_token.get_access_token(oauth_verifier: @verifier)
    end
  end
end
