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

run App.new
