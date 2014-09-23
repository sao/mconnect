module Mconnect
  module Helpers
    def load_yaml data
      if data.kind_of? Hash
        YAML.load(data.to_yaml)
      else
        YAML.load_file(data)
      end
    end
  end
end
