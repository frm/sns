defmodule SNS.Local.Server do
  use SNS, scheme: :http, port: 8080

  def start do
    start_link([])
  end

  def handle(message) do
    SNS.Local.Handler.handle(message)
  end
end
