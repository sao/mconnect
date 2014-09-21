require 'pry'
module Mconnect
  class Decorator
    attr_accessor :content

    def initialize content
      @content = content
    end

    def yank_column column
      orig_content = self.content.dup
      self.content = []

      orig_content.each do |hash|
        self.content << hash[column]
      end

      self.content.flatten!
    end

    def remove_columns columns = []
      self.content.each do |hash|
        hash.reject! do |k,v|
          columns.include? k
        end
      end
    end
  end

  class Generator
    attr_accessor :content
    attr_reader   :filename, :endpoint

    def initialize filename, endpoint
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
        @content = decorator.yank_column 'standards'
      when "sections"
        orig_content = @content.dup
        @content      = []

        orig_content.each do |hash|
          hash['teachers'].each do |t|
            hash['students'].each do |s|
              @content << {
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

      CSV.open(@filename, "w", write_headers: true, headers: @content.first.keys) do |csv|
        @content.each do |hash|
          csv << hash.values
        end
      end
    end
  end
end
