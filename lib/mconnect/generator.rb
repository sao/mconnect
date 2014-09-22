module Mconnect
  class Generator
    attr_accessor :content
    attr_reader   :filename, :endpoint

    def initialize content, filename, endpoint
      @content  = content
      @filename = filename
      @endpoint = endpoint
    end

    def save_csv
      decorator = Mconnect::Decorator.new @content

      case @endpoint
      when "teachers"
        @content = decorator.remove_columns ['custom', 'saml_name']
      when "students"
        @content = decorator.remove_columns ['sections']
      when "standards"
        @content = decorator.flatten_column 'standards'
      when "sections"
        @content = decorator.sections_hash
      end

      CSV.open(@filename, "w", write_headers: true, headers: @content.first.keys) do |csv|
        @content.each do |hash|
          csv << hash.values
        end
      end
    end
  end
end
