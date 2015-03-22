require 'Socket'

class Echo
  Chunk=0x10000

  def self.run!
    puts "Server is listening..."
    Socket.tcp_server_loop 'localhost', 8081 do |client, addr|
      puts "Connected from #{addr.ip_address}:#{addr.ip_port}"
      new client
    end
  end

  def initialize client
    @client=client
    Thread.new{loop!}
  end

  def loop!
    begin
      puts "<Client>"
      loop
    rescue=>e
      puts "Error: #{e}"
    ensure
      puts "</Client>"
      @client.close
    end
  end

  def loop
    @client.puts "Hello"
    until @client.eof
      s=@client.readpartial Chunk
      puts "Got #{s.length} byte"
      @client.puts "Got: #{s}"
    end
  end

  run!
end
