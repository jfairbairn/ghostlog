require 'fiber'
require 'thin'

puts 'patching thin'
module Thin
  class Connection
    def receive_data(data)
      trace { data }
      Fiber.new{process}.resume if @request.parse(data)
    rescue InvalidRequest => e
      log "!! Invalid request"
      log_error e
      close_connection
    end
  end
end
