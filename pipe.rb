#Test: in console, just curl localhost:3003/
#You can get the response
require 'socket'
require 'debugger'
require 'http/parser'
require 'stringio'


class Pipe
  def initialize(port, app)
    @server = TCPServer.new(port)
    @app = app
  end

  def start
    loop do
      socket = @server.accept
      connection = Connection.new(socket, @app)
      connection.process
    end
  end


  class Connection
    def initialize(socket, app)
      @socket = socket
      @parser = Http::Parser.new(self)
      @app = app
    end

    def process
      until @socket.closed? || @socket.eof?
        data = @socket.readpartial(1024)
        @parser << data
      end
    end

    def on_message_complete
      puts "#{@parser.http_method} #{@parser.request_path}"
      puts " " + "#{@parser.headers.inspect}"

      env = {}
      @parser.headers.each do |k, v|
        env["HTTP_#{k.upcase.tr('-', '_')}"] = v
      end
      env["PATH_INFO"] = @parser.request_path
      env["REQUEST_METHOD"] = @parser.http_method
      env["rack.input"] = StringIO.new

      send_response(env)
      close
    end

    REASONS = {
      200 => "OK",
      404 => "Not found"
    }

    def send_response(env)
      status, header, body = @app.call(env)
      reason = REASONS[status]

      response = "HTTP/1.1 #{status} #{REASONS[status]}\r\n"

      header.each do |k, v|
        response += "#{k} : #{v}\r\n"
      end

      response += "\r\n"
      #The rack application should return a body respond to each method
      body.each do |chunk|
        response += "#{chunk}"
      end

      body.close if body.respond_to? :close

      @socket.write(response)
    end

    def close
      @socket.close
    end
  end

end

class App
  def call(env)
    message = "this is response from app\n"
    [
      200,
      {"Content-Type" => "text/plain", "Content-Length" => "#{message.size}"},
      [message]
    ]
  end
end

app = App.new
server = Pipe.new(3003, app)
p "You have a server for 3003"
server.start

