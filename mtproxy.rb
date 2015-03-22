require 'Socket'

Thread.abort_on_exception=true

class Proxy
  Chunk=0x10000

  def self.run!
    puts "Proxy is listening..."
    Socket.tcp_server_loop 'localhost', 8082 do |client, addr|
      puts "Connected from #{addr.ip_address}:#{addr.ip_port}"
      self.new client
    end
  end

  def initialize client
    @client=client
    @t1=Thread.new{cloop}
  end

  # Client loop
  def cloop
    puts "Connecting to server..."
    @server=Socket.tcp 'localhost', 8081
    puts "Connected to server"
    @t2=Thread.new{sloop}
    until @client.eof
      s=@client.readpartial Chunk
      puts "> #{s.length}"
      @server.write s
    end
    puts "Client closed"
    @t2.exit
  end

  # Server loop
  def sloop
    until @server.eof do
      s=@server.readpartial Chunk
      puts "< #{s.length}"
      @client.write s
    end
    puts "Server closed"
    @t1.exit
  end

  run!
end
