require 'Socket'

puts "Listening..."

sock=Addrinfo.tcp('127.0.0.1', 8081).listen

while true
  Thread.start sock.accept do |client, addr|
    puts "Connected from #{addr.ip_address}:#{addr.ip_port}"
    client.puts "Hello!"
    while true
      s=client.readpartial 4096
      puts "Got #{s.length} byte"
      client.puts "Got: #{s}"
    end
    client.close
  end
end
