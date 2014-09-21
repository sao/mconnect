module Mconnect
  module Helpers
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
  end
end
