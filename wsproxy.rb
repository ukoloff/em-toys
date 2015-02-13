require 'em-websocket'

module Client
  attr_accessor :ws

  def post_init
    puts "<Client Connect>"
  end

  def receive_data data
    puts "Got from server #{data.length}: #{data.strip.gsub /\s+/, ' '}\n"
    ws.send data
  end

  def unbind
    puts "</Client Connect>"
    ws.close
  end
end


EM.run do
  EM::WebSocket.run host: "0.0.0.0", port: 8088, debug: true do |ws|

    client = nil

    ws.onopen do |handshake|
      puts "WebSocket connection open at #{handshake.path}"
      EM.connect 'localhost', 8081, Client do |conn|
        client = conn
        client.ws = ws
      end
    end

    ws.onclose do
      client.close_connection if client
    end

    ws.onbinary do |msg|
      puts "Recieved message: #{msg}"
      client.send_data msg
    end
  end
end
