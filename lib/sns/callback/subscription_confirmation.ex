defmodule SNS.Callback.SubscriptionConfirmation do
  def handle(%{"SubscribeURL" => subscribe_url}, _opts) do
    # TODO: add signature confirmation
    case :hackney.get(subscribe_url) do
      {:ok, 200, _, _} -> {:ok, 200}
      {:ok, status, _, _} -> {:error, status}
      {:error, reason} -> {:error, reason}
    end
  end

  def handle(_, _), do: {:error, :badarg}
end
