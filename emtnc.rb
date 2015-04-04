require 'socket'
require 'eventmachine'

STDERR.reopen __FILE__+'.log', 'w'

STDOUT.sync=true
STDERR.sync=true
STDIN.binmode
STDOUT.binmode

class Stdio
  Chunk=0x10000
  def initialize srv
    @srv=srv
    @t=Thread.new{loop}
  end

  def loop
    begin
      until STDIN.eof
        @srv.send_data STDIN.readpartial Chunk
      end
    rescue=>e
      STDERR.puts "Client error #{e}"
    ensure
      EM.stop
    end
  end

  def bye
    @t.exit
  end
end

module Server
  def post_init
    STDERR.puts "Connected to server"
    @stdio=Stdio.new self
  end

  def receive_data data
    STDOUT << data
  end

  def unbind
    STDERR.puts "Server disconnected"
    @stdio.bye
  end
end

EM.run do
  EM.connect 'localhost', 8081, Server
end
