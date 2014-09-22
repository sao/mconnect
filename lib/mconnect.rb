require 'mconnect/version'
require 'thor'
require 'oauth'
require 'yaml'
require 'json'
require 'csv'

require 'mconnect/helpers'
require 'mconnect/worker'
require 'mconnect/decorator'
require 'mconnect/generator'
require 'mconnect/authorizer'
require 'mconnect/verifier'

module Mconnect
  class CLI < Thor
    MISSING_CONFIG_MESSAGE = "Missing config file. Please run 'config' first."

    desc "config", "create a new configuration yaml (/tmp/mconnect.yml)"
    def config options = {}
      puts "Let's setup a configuration file.."

      write_option 'What is the consumer key?', 'consumer_key', options
      write_option 'What is the consumer secret?', 'consumer_secret', options

      save_to_yaml options, '/tmp/mconnect.yml'
    end

    desc "auth", "authorize client and create authorization yaml (/tmp/mconnect_authorization.yml)"
    def auth
      begin
        authorizer    = Mconnect::Authorizer.new.client
        request_token = authorizer.get_request_token

        verifier      = Mconnect::Verifier.new request_token
        save_to_yaml verifier.authorization, '/tmp/mconnect_authorization.yml'
      rescue
        puts MISSING_CONFIG_MESSAGE
      end
    end

    desc "get", "gets endpoint and saves to CSV"
    option :e, required: true
    option :o, required: true
    def get
      begin
        filename     = options[:o].to_s
        endpoint     = options[:e]
        authorizer   = Mconnect::Authorizer.new
        worker       = Mconnect::Worker.new authorizer.client, authorizer.access_token, endpoint
        generator    = Mconnect::Generator.new(worker.get_content, filename, endpoint)

        generator.save_csv
      rescue
        puts MISSING_CONFIG_MESSAGE
      end
    end

    no_commands {
      include Helpers
    }
  end
end

