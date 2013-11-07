#Test: in console, just curl localhost:3003/
#You can get the response
require 'socket'

class Pipe
  def initialize(port)
    @server = TCPServer.new(port)
  end

  def start
    socket = @server.accept
    data = socket.readpartial(1024)
    p data

    socket.write(response)
  end

  def response
    "HTTP/1.1 200 OK\r\n" +
    "\r\n" +
    "You are getting response"
  end
end

server = Pipe.new(3003)
p "You have a server for 3003"
server.start

