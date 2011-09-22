require File.dirname(__FILE__) + '/http_client'
require 'cgi'
require 'json'
require 'pp'

module Ghostlog
  class SearchIndex
    def initialize(config)
      config = config[:elasticsearch]
      @index = config[:index]
      @client = HttpClient.new(config[:host], config[:port])
    end
    
    def create
      @client.put("/#{@index}/")
      @client.put("/#{@index}/document/_mapping", schema_json)
    end
    
    def delete
      @client.delete("/#{@index}/")
    end
    
    def put(doc, id=nil)
      @client.put("/#{@index}/document/#{id}", doc.to_json)
    end
    
    def search(params={})
      res = JSON.parse(@client.post("/#{@index}/document/_search", params.to_json).body)
      raise "Query error: #{res['error']}" if res.has_key?('error')
      res
    end
    
    def get(id)
      JSON.parse(@client.get("/#{@index}/document/#{id}?fields=content").body)
    end
    
    private
    def schema_json
      path = File.expand_path('es_schema.json', File.join(File.dirname(__FILE__), '..'))
      File.read(path)
    end
  end
end