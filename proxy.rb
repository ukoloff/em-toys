require 'eventmachine'

module Proxy
  attr_accessor :client

  def post_init
    puts "<Connect>"
    puts "Reconnecting to server..."
    EM.connect 'localhost', 8081, Client do |conn|
      self.client = conn
      conn.originator = self
    end
  end

  def receive_data data
    puts "Got from user #{data.length}: #{data.strip.gsub /\s+/, ' '}\n"
    client.send_data data
  end

  def unbind
    puts "</Connect>"
    client.close_connection if client
  end
end

module Client
  attr_accessor :originator

  def post_init
    puts "<Client Connect>"
  end

  def receive_data data
    puts "Got from server #{data.length}: #{data.strip.gsub /\s+/, ' '}\n"
    originator.send_data data
  end

  def unbind
    puts "</Client Connect>"
    originator.close_connection
  end
end

EM.run do
  EM.start_server "127.0.0.1", 8082, Proxy
end
