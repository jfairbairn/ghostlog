require 'json'

module Ghostlog
  class FileStore
    def initialize(config)
      @directory = config[:directory]
      FileUtils.mkdir_p(@directory)
    end
    
    def save(filename, content_type, io)
      dir = @directory
      if filename.size > 4
        dir = File.join(@directory, filename[0..1], filename[2..3])
      end
      FileUtils.mkdir_p(dir)
      File.open(File.expand_path(filename, dir), 'wb') do |f|
        while s = io.read(32768)
          f.write(s)
        end
      end
      File.open(File.expand_path("#{filename}.meta", dir), 'wb') {|f|f.write({type: content_type}.to_json)}
    end
  end
end