defmodule SNS.API do
  @callback subscribe(binary, binary, binary, keyword) :: {:ok, any} | {:error, atom}
  @callback confirm_subscription(binary, binary, keyword) :: {:ok, any} | {:error, atom}
  @callback publish(binary, keyword) :: {:ok, any} | {:error, atom}

  import SNS.Config, only: [config!: 1]

  def subscribe(topic, protocol, endpoint, opts \\ []) do
    adapter().subscribe(topic, protocol, endpoint, opts)
  end

  def confirm_subscription(topic_arn, token, opts) do
    adapter().confirm_subscription(topic_arn, token, opts)
  end

  def publish(message, opts \\ []) do
    adapter().publish(message, opts)
  end

  defp adapter do
    config!(:adapter)
  end
end
