module Mconnect
  class Verifier
    attr_reader :request_token, :verifier_input

    def initialize request_token
      @request_token = request_token

      puts "Copy and paste the following URL in your browser:"
      puts "\t#{@request_token.authorize_url}"
      puts "When you sign in, copy and paste the oauth verifier here:"

      @verifier_input = $stdin.gets.strip
    end

    def authorization
      request_token.get_access_token(:oauth_verifier => verifier_input)
    end
  end
end
