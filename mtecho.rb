require 'Socket'

puts "Server is listening..."

Socket.tcp_server_loop 'localhost', 8081 do |client, addr|
  puts "Connected from #{addr.ip_address}:#{addr.ip_port}"
  Thread.new client do |client|
    client.puts "Hello!"
    until client.eof
      s=client.readpartial 4096
      puts "Got #{s.length} byte"
      client.puts "Got: #{s}"
    end
    puts "Connection ended"
    client.close
  end
end
