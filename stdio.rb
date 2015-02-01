require 'eventmachine'

module Stdio

 def post_init
   puts "<Connect>"
 end

 def receive_data data
   puts "Got #{data.length}: #{data.strip.gsub /\s+/, ' '}"
 end

 def unbind
   puts "</Connect>"
 end
end

EM.run do
  EM.attach $stdin, Stdio
end
