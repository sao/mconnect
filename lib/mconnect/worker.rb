module Mconnect
  class Worker
    attr_accessor :content

    def initialize access_token, endpoint
      @access_token   = access_token
      @endpoint       = endpoint

      get_content
    end

    def get_content page_number = 1
      @content ||= []

      url = "/api/#{@endpoint}?page=#{page_number}"

      @content << JSON.parse(@access_token.get(url, 'x-li-format' => 'json').body)
      @content.flatten!

      unless @content.count < page_number * 1000
        puts "Getting page #{page_number}.."
        get_content (page_number + 1)
      end
    end
  end
end
