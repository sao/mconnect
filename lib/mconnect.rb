require 'mconnect/version'
require 'thor'
require 'oauth'
require 'yaml'
require 'json'
require 'csv'

require 'pry'
require 'mconnect/helpers'

module Mconnect
  class CLI < Thor
    desc "config", "create a new configuration yaml (/tmp/mconnect.yml)"
    def config options = {}
      puts "Let's setup a configuration file.."

      write_option 'What is the api host?', 'api_host', options
      write_option 'What is the authorize path?', 'authorize_path', options
      write_option 'What is the request token path?', 'request_token_path', options
      write_option 'What is the access token path?', 'access_token_path', options
      write_option 'What is the consumer key?', 'consumer_key', options
      write_option 'What is the consumer secret?', 'consumer_secret', options

      save_to_yaml options, 'mconnect.yml'
    end

    desc "auth", "authorize client and create authorization yaml (/tmp/mconnect_authorization.yml)"
    def auth
      client_options = { :site => oauth_options['api_host'],
                         :authorize_path => oauth_options['authorize_path'],
                         :request_token_path => oauth_options['request_token_path'],
                         :access_token_path => oauth_options['access_token_path'] }

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
    option :d, required: true
    def get
      begin
        parsed_endpoint = options[:e].split('/').last

        get_content options[:e]
        save_csv @content, "#{options[:d]}/#{parsed_endpoint}.csv", parsed_endpoint
      rescue
        puts "Missing a configuration file. Please run 'status' to check on them."
      end
    end

    desc "status", "check status on configuration files"
    def status
      puts "initial config: #{oauth_options.class == String ? "missing" : "good"}"
      puts "auth config: #{access_token.class == String ? "missing" : "good"}"
    end

    no_commands {
      def oauth_options
        begin
          load_yaml '/tmp/mconnect.yml'
        rescue
          "missing initial config file"
        end
      end

      def access_token
        begin
          load_yaml '/tmp/mconnect_authorization.yml'
        rescue
          "missing authorization file"
        end
      end

      def load_yaml filename
        YAML.load_file(filename)
      end

      def save_to_yaml hash, filename
        File.open("/tmp/#{filename}", "w") do |file|
          file.write hash.to_yaml
        end
      end

      def write_option text, key, hash
        puts text
        input_value = $stdin.gets.strip
        hash[key] = input_value
      end

      def get_content endpoint, page_number = 1
        @content ||= []

        url = "/#{endpoint}?page=#{page_number}"

        @content << JSON.parse(access_token.get(url, 'x-li-format' => 'json').body)
        @content.flatten!

        if @content.count < page_number * 1000
          return
        else
          puts "Getting page #{page_number}.."
          get_content endpoint, (page_number + 1)
        end
      end

      def save_csv content, filename, endpoint_tail = ""
        # teacher csv specific
        if endpoint_tail == "teachers"
          content.each do |hash|
            hash.reject! do |k,v|
              ["custom", "saml_name"].include? k
            end
          end
        end

        # students csv specific
        if endpoint_tail == "students"
          content.each do |hash|
            hash.reject! do |k,v|
              ["sections"].include? k
            end
          end
        end

        # standards csv specific
        if endpoint_tail == "standards"
          orig_content = content.dup
          content      = []

          orig_content.each do |hash|
            content << hash['standards']
          end

          content.flatten!
        end

        # sections csv specific
        if endpoint_tail == "sections"
          orig_content = content.dup
          content      = []

          orig_content.each do |hash|
            hash['teachers'].each do |t|
              hash['students'].each do |s|
                content << {
                  "id"                 => hash['id'],
                  "school_id"          => hash['school_id'],
                  "name"               => hash['name'],
                  "teacher_id"         => t['id'],
                  "teacher_school_id"  => t['school_id'],
                  "teacher_first_name" => t['first_name'],
                  "teacher_last_name"  => t['last_name'],
                  "teacher_custom"     => t['custom'],
                  "student_id"         => s['id'],
                  "student_first_name" => s['first_name'],
                  "student_last_name"  => s['last_name'],
                  "student_number"     => s['student_number'],
                  "student_school_id"  => s['school_id'],
                  "student_custom"     => s['custom']
                }
              end
            end
          end
        end

        CSV.open(filename, "w", write_headers: true, headers: content.first.keys) do |csv|
          content.each do |hash|
            csv << hash.values
          end
        end
      end
    }
  end
end

