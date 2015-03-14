require 'Socket'

puts "Proxy is listening..."

Socket.tcp_server_loop 'localhost', 8082 do |client, addr|
  puts "Connected from #{addr.ip_address}:#{addr.ip_port}"
  Thread.new client do |client|
    srv=nil
    Thread.new do |t|
      puts "Connecting to server..."
      srv=Socket.tcp 'localhost', 8081
      puts "Connected to server"
      until srv.eof do
        s=srv.readpartial 4096
        puts "< #{s.length}"
        client.write s
      end
      puts "Server closed"
      client.close
    end
    until client.eof
      s=client.readpartial 4096
      puts "> #{s.length}"
      srv.write s
    end
    puts "Client closed"
    client.close
    srv.close if srv
  end
end
