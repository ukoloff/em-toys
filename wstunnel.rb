require 'Socket'
require 'openssl'
# require 'openssl/win/root'

Host='ya.ru'

puts "WSTunnel is listening..."

Thread.abort_on_exception=true

def reheaders headers
  return headers if headers.length<1
  verb=headers.shift
  [verb]+
  %w(Host Origin).map{|h| "#{h}: #{Host}"}+
  headers.reject{|h| /^(?:host|origin):/i.match h}
end

def read_headerz stream
  r=[]
  until stream.eof
    s=stream.gets.strip
    break if 0==s.length
    r << s
  end
  r
end

def req client
  headers=reheaders  read_headerz client
  puts "New headers: ", headers.map{|h| "\t#{h}"}

  puts "Connecting to server..."
  srv=OpenSSL::SSL::SSLSocket.new Socket.tcp Host, 443
  srv.hostname=Host if srv.respond_to? :hostname=
  srv.connect
  puts "Connected to server"
  srv.write headers*"\r\n"+"\r\n\r\n"
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

Socket.tcp_server_loop 'localhost', 8082 do |client, addr|
  puts "Connected from #{addr.ip_address}:#{addr.ip_port}"
  Thread.new{req client}
end
