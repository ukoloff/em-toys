require 'eventmachine'
# Here's a program which connects to a web server, sends a naive
# request, parses the HTTP header of the response, and then
# (antisocially) ends the event loop, which automatically drops the connection
# (and incidentally calls the connection's unbind method).
module DumbHttpClient
  def post_init
    send_data "GET / HTTP/1.1\r\nHost: _\r\n\r\n"
    @data = ""
    @parsed = false
  end

  def receive_data data
    @data << data
    if !@parsed and @data =~ /[\n][\r]*[\n]/m
      @parsed = true
      puts "RECEIVED HTTP HEADER:"
#      $`.each {|line| puts ">>> #{line}" }
      puts @data

      puts "Now we'll terminate the loop, which will also close the connection"
      EventMachine::stop_event_loop
    end
  end

  def unbind
    puts "A connection has terminated"
  end
end

EM.run {
  EM.connect "ya.ru", 80, DumbHttpClient
}
puts "The event loop has ended"
