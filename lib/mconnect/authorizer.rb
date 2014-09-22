module Mconnect
  class Authorizer
    include Helpers

    attr_reader :oauth_options, :client_options

    def initialize
      @oauth_options  = load_yaml '/tmp/mconnect.yml'
      @client_options = { :site => 'https://api.masteryconnect.com',
                          :authorize_path => '/oauth/authorize',
                          :request_token_path => '/oauth/request_token',
                          :access_token_path => '/oauth/access_token' }
    end

    def access_token
      access_token = load_yaml '/tmp/mconnect_authorization.yml'
      OAuth::AccessToken.new(client, access_token.token, access_token.secret)
    end

    def client
      OAuth::Consumer.new(
        oauth_options['consumer_key'],
        oauth_options['consumer_secret'],
        client_options
      )
    end
  end
end
