require 'uri'
require 'net/http'

require 'json'

module Ghostlog
  class AvatarCache
    def get(username)
      username.downcase!
      populate unless @cache
      result = @cache[username]
      if result.nil?
        result = fetch(username)[0]
        if result.nil?
          result = :not_found
        else
          result = qualify(result['small'])
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
        @cache[user['username']] = qualify(user['small'])
      end
    end
    
    def qualify(uri)
      u = URI.parse(uri)
      u.host += '.medmol.local' if u.host == 'intranet'
      u.to_s
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
      begin
        JSON.parse(body)
      rescue
        []
      end
    end
  end
end