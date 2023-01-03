defmodule SNS.Callback.Notification do
  def handle(%{"Message" => message}, opts) do
    handler = Keyword.fetch!(opts, :handler)
    handler.handle(message)

    {:ok, 200}
  end

  def handle(_, _), do: {:error, :badarg}
end
