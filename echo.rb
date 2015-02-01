require 'eventmachine'

module Echo

 def post_init
   puts "<Connect>"
 end

 def receive_data data
   send_data "Got #{data.length}: #{data.strip.gsub /\s+/, ' '}\n"
 end

 def unbind
   puts "</Connect>"
 end
end

EM.run do
  EM.start_server "127.0.0.1", 8081, Echo
end
