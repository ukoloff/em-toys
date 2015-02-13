require 'em-websocket'

EM.run do
  EM::WebSocket.run host: "0.0.0.0", port: 8080, debug: true do |ws|
    ws.onopen do |handshake|
      puts "WebSocket connection open"
      ws.send "Hello Client, you connected to #{handshake.path}\n"
    end

    ws.onclose do
      puts "Connection closed"
    end

    ws.onbinary do |msg|
      puts "Recieved message: #{msg}"
      ws.send "Pong: #{msg}"
    end
  end
end
