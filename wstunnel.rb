require 'Socket'
require 'openssl'
# require 'openssl/win/root'

Host='ya.ru'

puts "WSTunnel is listening..."

Socket.tcp_server_loop 'localhost', 8082 do |client, addr|
  puts "Connected from #{addr.ip_address}:#{addr.ip_port}"
  Thread.new client do |client|
    puts "Connecting to server..."
    srv=OpenSSL::SSL::SSLSocket.new Socket.tcp Host, 443
    srv.hostname=Host if srv.respond_to? :hostname=
    srv.connect
    puts "Connected to server"
    Thread.new do |t|
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
