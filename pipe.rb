#Test: in console, just curl localhost:3003/
#You can get the response
require 'socket'
require 'debugger'

class Pipe
  def initialize(port)
    @server = TCPServer.new(port)
  end

  def start
    loop do
      socket = @server.accept
      connection = Connection.new(socket)
      connection.process
    end
  end


  class Connection
    def initialize(socket)
      @socket = socket
    end

    def process
      data = @socket.readpartial(1024)
      p data

      send_response
      close
    end

    def send_response
      response = "HTTP/1.1 200 OK\r\n" +
        "\r\n" +
        "You are getting response"

      @socket.write(response)
    end

    def close
      @socket.close
    end
  end
end

server = Pipe.new(3003)
p "You have a server for 3003"
server.start

