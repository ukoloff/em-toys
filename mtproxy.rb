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
    @t1=Thread.new{cloop!}
  end

  # Client loop
  def cloop
    puts "Connecting to server..."
    @server=Socket.tcp 'localhost', 8081
    @t2=Thread.new{sloop!}
    until @client.eof
      s=@client.readpartial Chunk
      puts "> #{s.length}"
      @server.write s
    end
  end

  # Protected client loop
  def cloop!
    begin
      puts "<Client>"
      cloop
    rescue=>e
      puts "Client error: #{e}"
    ensure
      puts "</Client>"
      @client.close
      @t2.exit if @t2
    end
  end

  # Server loop
  def sloop
    until @server.eof do
      s=@server.readpartial Chunk
      puts "< #{s.length}"
      @client.write s
    end
  end

  # Protected server loop
  def sloop!
    begin
      puts "<Server>"
      sloop
    rescue=>e
      puts "Server error: #{e}"
    ensure
      puts "</Server>"
      @server.close
      @t1.exit
    end
  end

  run!
end
