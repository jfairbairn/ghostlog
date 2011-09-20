require File.dirname(__FILE__) + '/http_client'
require 'cgi'
require 'json'

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
    
    def put(doc, id=nil)
      @client.post("/#{@index}/document/", doc.to_json)
    end
    
    def search(qstr)
      qstr_escaped = CGI.escape(qstr)
      JSON.parse(@client.get("/#{@index}/document/_search?q=#{qstr_escaped}").body)
    end
    
    private
    def schema_json
      path = File.expand_path('es_schema.json', File.join(File.dirname(__FILE__), '..'))
      File.read(path)
    end
  end
end