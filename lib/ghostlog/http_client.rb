require 'net/http'
require 'em-net-http'

module Ghostlog
  class HttpClient
    def initialize(host, port)
      @host = host
      @port = port
    end
    
    def get(url, headers={})
      request(Net::HTTP::Get, url, nil, headers)
    end
    
    def post(url, body='', headers={})
      request(Net::HTTP::Post, url, body, headers)
    end
    
    def put(url, body='', headers={})
      request(Net::HTTP::Put, url, body, headers)
    end
    
    def delete(url, body='', headers={})
      request(Net::HTTP::Delete, url, body, headers)
    end
    
    private
    def request(klass, url, body, headers)
      Net::HTTP.new(@host, @port).start do |http|
        req = klass.new(url)
        req.body = body if body
        headers.each do |k, v|
          req[k] = v
        end
        http.request(req)
      end
    end

  end
end