require 'Socket'

puts "Listening..."

sock=Addrinfo.tcp('127.0.0.1', 8082).listen

while true
  Thread.start sock.accept do |client, addr|
    puts "Connected from #{addr.ip_address}:#{addr.ip_port}"
    srv=nil
    Thread.new do |t|
      # t.abort_on_exception=true
      puts "Connecting to server..."
      srv=Socket.tcp 'localhost', 8081
      puts "Connected to server"
      until srv.eof do
        s=srv.readpartial 4096
        puts "< #{s.length}"
        client.write s
      end
      puts "Server closed"
    end
    until client.eof
      s=client.readpartial 4096
      puts "> #{s.length}"
      srv.write s
    end
    puts "Client closed"
    client.close
  end
end
