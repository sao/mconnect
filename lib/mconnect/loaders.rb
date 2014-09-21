module Mconnect
  module Loaders
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
  end
end
