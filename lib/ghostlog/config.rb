require 'yaml'

module Ghostlog
  class Config
    def initialize(filename)
      raise "Config file #{filename.inspect} not found!" unless File.exist? filename
      @config = symbolise_keys(YAML.load(File.read(filename)))
    end
    
    def symbolise_keys(h)
      if h.is_a? Hash
        hnew = {}
        h.each do |k, v|
          hnew[k.to_sym] = symbolise_keys(v)
        end
        hnew
      else
        h
      end
    end
    
    def [](k)
      @config[k]
    end
    
  end
end