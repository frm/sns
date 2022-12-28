defmodule SNS.Dev.Server do
  use SNS, scheme: :http, port: 8080

  def start do
    start_link([])
  end

  def handle(message) do
    SNS.Dev.Handler.handle(message)
  end
end
