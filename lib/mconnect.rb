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
    option :site, default: "https://api.masteryconnect.com", desc: "MasteryConnect API URL"
    def config user_input={}
      say "Let's setup a configuration file.."

      user_input['consumer_key']    = ask('What is the consumer key?').to_s
      user_input['consumer_secret'] = ask('What is the consumer secret?').to_s
      user_input['site'] = ask('What is the MasteryConnect API URL?', default: options[:site])

      create_file "#{Dir.home}/.mconnect/config.yml" do
        user_input.to_yaml
      end
    end

    desc "auth", "authorize client and create authorization yaml"
    def auth
      authorizer = Mconnect::Authorizer.new

      say 'Copy and paste the following URL in your browser:'
      say "\t#{authorizer.authorize_url}"

      authorizer.verifier = ask('When you sign in, copy and paste the oauth verifier here:').to_s

      create_file "#{Dir.home}/.mconnect/authorization.yml" do
        authorizer.authorization.to_yaml
      end
    end

    desc "get", "gets endpoint and saves to CSV"
    option :e, required: true, desc: "which endpoint to export"
    option :o, required: true, desc: "destination to put CSV"
    def get
      directory  = options[:o].to_s
      endpoint   = options[:e].to_s
      authorizer = Mconnect::Authorizer.new
      worker     = Mconnect::Worker.new authorizer.access_token, endpoint
      generator  = Mconnect::Generator.new(worker.content, directory, endpoint)

      generator.save_csv
    end
  end
end

