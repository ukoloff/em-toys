require 'Socket'

Thread.abort_on_exception=true

puts "Proxy is listening..."

Socket.tcp_server_loop 'localhost', 8082 do |client, addr|
  puts "Connected from #{addr.ip_address}:#{addr.ip_port}"
  t1=Thread.new client do |client|
    srv=nil
    puts "Connecting to server..."
    srv=Socket.tcp 'localhost', 8081
    puts "Connected to server"
    t2=Thread.new do
      until srv.eof do
        s=srv.readpartial 4096
        puts "< #{s.length}"
        client.write s
      end
      puts "Server closed"
      t1.exit
    end
    until client.eof
      s=client.readpartial 4096
      puts "> #{s.length}"
      srv.write s
    end
    puts "Client closed"
    t2.exit
  end
end
