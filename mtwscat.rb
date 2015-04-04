require 'socket'
require "faye/websocket"

STDERR.reopen __FILE__+'.log', 'w'

STDOUT.sync=true
STDERR.sync=true
STDIN.binmode
STDOUT.binmode

class Stdio
  Chunk=0x10000
  def initialize ws
    @ws=ws
    @t=Thread.new{loop}
  end

  def loop
    begin
      until STDIN.eof
        @ws.send STDIN.readpartial Chunk
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

class Ws
  def initialize uri
    @ws=Faye::WebSocket::Client.new uri

    @ws.on :open do |event| onopen end
    @ws.on :message do |event| onmessage event.data end
    @ws.on :close do |event| onclose end
    @ws.on :error do |error| onerror error end
  end

  def send data
    @ws.send data.unpack 'C*'
  end

  def onopen
    STDERR.puts "Websocket connected"
    @stdio=Stdio.new self
  end

  def onmessage data
    STDOUT << data.pack('C*')
  end

  def onclose
    STDERR.puts "Websocket closed"
    bye
  end

  def onerror error
    STDERR.puts "Websocket error: #{error}"
    bye
  end

  def bye
    @stdio.bye if @stdio
  end
end

EM.run{ Ws.new 'http://localhost:4567/test/self' }
