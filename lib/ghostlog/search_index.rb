require File.dirname(__FILE__) + '/http_client'

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
    
    private
    def schema_json
      path = File.expand_path('es_schema.json', File.join(File.dirname(__FILE__), '..'))
      File.read(path)
    end
  end
end