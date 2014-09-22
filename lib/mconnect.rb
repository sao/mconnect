require 'mconnect/version'
require 'thor'
require 'oauth'
require 'yaml'
require 'json'
require 'csv'

require 'mconnect/helpers'
require 'mconnect/loaders'
require 'mconnect/worker'
require 'mconnect/decorator'
require 'mconnect/generator'

module Mconnect
  class CLI < Thor
    desc "config", "create a new configuration yaml (/tmp/mconnect.yml)"
    def config options = {}
      puts "Let's setup a configuration file.."

      write_option 'What is the consumer key?', 'consumer_key', options
      write_option 'What is the consumer secret?', 'consumer_secret', options

      save_to_yaml options, 'mconnect.yml'
    end

    desc "auth", "authorize client and create authorization yaml (/tmp/mconnect_authorization.yml)"
    def auth
      client_options = { :site => 'https://api.masteryconnect.com',
                         :authorize_path => '/oauth/authorize',
                         :request_token_path => '/oauth/request_token',
                         :access_token_path => '/oauth/access_token' }

      client = OAuth::Consumer.new(
        oauth_options['consumer_key'],
        oauth_options['consumer_secret'],
        client_options
      )

      request_token = client.get_request_token
      puts "Copy and paste the following URL in your browser:"
      puts "\t#{request_token.authorize_url}"
      puts "When you sign in, copy and paste the oauth verifier here:"
      verifier = $stdin.gets.strip

      authorization = request_token.get_access_token(:oauth_verifier => verifier)
      save_to_yaml authorization, 'mconnect_authorization.yml'
    end

    desc "get", "gets endpoint and saves to CSV"
    option :e, required: true
    option :o, required: true
    def get
      filename  = "#{options[:o]}"
      endpoint  = options[:e]
      worker    = Mconnect::Worker.new access_token, endpoint
      generator = Mconnect::Generator.new(filename, endpoint)

      generator.content = worker.get_content
      generator.save_csv
    end

    desc "status", "check status on configuration files"
    def status
      puts "initial config: #{oauth_options.class == String ? "missing" : "good"}"
      puts "auth config: #{access_token.class == String ? "missing" : "good"}"
    end

    no_commands {
      include Helpers
      include Loaders
    }
  end
end

