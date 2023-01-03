defmodule SNS.API.AWS do
  @behaviour SNS.API

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

  def confirm_subscription(topic_arn, token, opts) do
    authenticate_on_unsubscribe = Keyword.get(opts, :authenticate_on_unsubscribe, false)

    ExAws.SNS.confirm_subscription(topic_arn, token, authenticate_on_unsubscribe)
    |> request()
  end

  def publish(message, opts \\ []) do
    ExAws.SNS.publish(message, opts)
    |> request()
  end

  defp request(request) do
    ExAws.request(request, aws_config())
  end

  defp aws_config do
    [
      secret_access_key: config!(:secret_access_key),
      access_key_id: config!(:access_key_id),
      region: config!(:region),
      host: host_with_prefix(),
      scheme: config!(:scheme)
    ]
  end

  defp host_with_prefix do
    "sns.#{config!(:region)}.#{config!(:host)}"
  end
end
