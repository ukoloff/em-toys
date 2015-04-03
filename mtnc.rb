require 'Socket'

class NetCat
  Chunk=0x10000

  def self.run!
    @t1=Thread.new{new.sloop}
    @t1.join
  end

  def cloop
    begin
      until STDIN.eof
        @client.write STDIN.readpartial Chunk
      end
    rescue=>e
      STDOUT.puts "Client error #{e}"
    ensure
      @t1.exit
    end
  end

  def sloop
    begin
      @client=@server=Socket.tcp 'localhost', 8081
      @t2=Thread.new{cloop}
      until @client.eof
        STDOUT.write @client.readpartial Chunk
      end
    rescue=>e
      STDOUT.puts "Server error #{e}"
    ensure
      @client.close if @client
      @t2.exit if @t2
    end
  end

  run!
end
