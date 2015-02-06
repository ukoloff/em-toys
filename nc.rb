require 'eventmachine'
require 'byebug'

module Stdio
  attr_accessor :ne

  def post_init
    puts "<Connect stdio>"
  end

  def receive_data data
    puts "stdio..."
    ne.send_data data
  end

  def unbind
    puts "</Connect stdio>"
  end
end

module Dst
  attr_accessor :usr

  def post_init
    puts "<Connect net>"
    send_data "Hi\n"
    puts "-"
  end

  def receive_data data
    puts "net...", data
    
#    usr.send_data data
  end

  def unbind
    puts "</Connect net>"
  end
end

EM.run do
  stdio = EM.attach $stdin, Stdio
  n = EM.connect 'localhost', 8081, Dst
  stdio.ne=n
  n.usr=stdio
  puts ".run."
end
