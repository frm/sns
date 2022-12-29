defmodule SNS.Callback.Notification do
  import SNS.Config, only: [config: 2]

  def handle(%{"Message" => message}) do
    subscription_handler().handle(message)

    {:ok, 200}
  end

  def handle(_), do: {:error, :badarg}

  defp subscription_handler do
    config(:subscription_handler, SNS.Local.Handler)
  end
end
