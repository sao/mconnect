module Mconnect
  class Decorator
    def initialize content
      @content = content
    end

    def remove_columns columns = []
      @content.each do |hash|
        hash.reject! do |k,v|
          columns.include? k
        end
      end
    end

    def flatten_column column
      orig_content = @content.dup
      content = []

      orig_content.each do |hash|
        content << hash[column]
      end

      content.flatten!
    end

    def sections_hash
      orig_content = @content.dup
      content = []

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

      return content
    end
  end
end
