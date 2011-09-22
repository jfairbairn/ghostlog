module Ghostlog
  module Importer
    def self.register(sym, klazz)
      @@importers||={}
      @@importers[sym] = klazz
    end
    
    def self.method_missing(sym, *args)
      @@importers[sym].new(*args)
    end
  end
end
    
%w(imap svn).each do |f|
  require File.dirname(__FILE__) + '/importers/' + f
end
