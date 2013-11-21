class App
  def call(env)
    sleep 5 if env["PATH_INFO"] == "/sleep"

    message = "this is response from app, PID: #{Process.pid}\n"
    [
      200,
      {"Content-Type" => "text/plain", "Content-Length" => "#{message.size}"},
      [message]
    ]
  end
end

run App.new
