require 'ostruct'

module Ghostlog
  class Document < OpenStruct
    def initialize(data)
      super
      data.each do |k, v|
        self.send(:"#{k}=", v)
      end
    end
  end
end