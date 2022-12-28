defmodule SNS.API do
  import SNS.Config, only: [config!: 1, config!: 2]

  def subscribe(topic_arn, protocol, endpoint, opts \\ [])

  def subscribe("arn:" <> _ = topic_arn, protocol, endpoint, opts) do
    ExAws.SNS.subscribe(topic_arn, protocol, endpoint, opts)
    |> request()
  end

  def subscribe(topic, protocol, endpoint, opts) do
    region = config!(:region)
    account_id = config!(:sns, :account_id)
    topic_arn = "arn:aws:sns:#{region}:#{account_id}:#{topic}"

    subscribe(topic_arn, protocol, endpoint, opts)
  end

  def confirm_subscription(topic_arn, token, authenticate_on_unsubscribe \\ false) do
    ExAws.SNS.confirm_subscription(topic_arn, token, authenticate_on_unsubscribe)
    |> request()
  end

  def publish(message, opts \\ []) do
    ExAws.SNS.publish(message, opts)
    |> request()
  end

  defp request(request) do
    ExAws.request(request, SNS.AWS.config())
  end
end
