require 'mconnect/version'
require 'thor'
require 'oauth'
require 'yaml'
require 'json'
require 'csv'

require 'mconnect/worker'
require 'mconnect/decorator'
require 'mconnect/generator'
require 'mconnect/authorizer'

module Mconnect
  class CLI < Thor
    include Thor::Actions

    desc "config", "create a new configuration yaml"
    def config options = {}
      say "Let's setup a configuration file.."

      options['consumer_key']    = ask('What is the consumer key?').to_s
      options['consumer_secret'] = ask('What is the consumer secret?').to_s

      create_file '/tmp/mconnect/config.yml' do
        options.to_yaml
      end
    end

    desc "auth", "authorize client and create authorization yaml"
    def auth
      say 'Copy and paste the following URL in your browser:'
      say "\t#{authorizer.authorize_url}"

      authorizer.verifier = ask('When you sign in, copy and paste the oauth verifier here:').to_s

      create_file '/tmp/mconnect/authorization.yml' do
        authorizer.authorization.to_yaml
      end
    end

    desc "get", "gets endpoint and saves to CSV"
    option :e, required: true, desc: "which endpoint to export"
    option :o, required: true, desc: "destination to put CSV"
    def get
      filename   = options[:o].to_s
      endpoint   = options[:e].to_s
      worker     = Mconnect::Worker.new authorizer.access_token, endpoint
      generator  = Mconnect::Generator.new(worker.content, filename, endpoint)

      generator.save_csv
    end

    no_commands {
      def authorizer
        Mconnect::Authorizer.new
      end
    }
  end
end

