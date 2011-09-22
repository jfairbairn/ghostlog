require 'json'
require 'net/http'

module Ghostlog
  class AvatarCache
    def get(username)
      username.downcase!
      populate unless @cache
      result = @cache[username]
      if result.nil?
        result = fetch(username)
        if result.nil?
          result = :not_found
        end
        @cache[username] = result
      end
      result = nil if result == :not_found
      result
    end
    
    private
    CALLBACK = /^[a-zA-Z0-9_]+\((.*)\);?$/
    
    def populate
      @cache = {}
      fetch.each do |user|
        @cache[user['username']] = user['small']
      end
    end
    
    def fetch(username=nil)
      q = username ? "?name=#{username}" : ''
      res = Net::HTTP.start('intranet', 80) do |http|
        req = Net::HTTP::Get.new("/_incs/staff_pics_json/#{q}")
        req['Accept-Encoding'] = ''
        http.request(req)
      end
      raise "Bad response #{res.code} - #{res.body}" unless res.code == '200'
      body = res.body
      body = $1 if body =~ CALLBACK
      JSON.parse(body)
    end
  end
end