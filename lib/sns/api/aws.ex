defmodule SNS.API.AWS do
  @behaviour SNS.API

  import SNS.Config, only: [config: 1, config!: 1, config!: 2]

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
    [region: config!(:region)]
    |> put_aws_config_value(:access_key_id)
    |> put_aws_config_value(:secret_access_key)
    |> put_aws_config_value(:scheme)
    |> put_host_with_prefix()
  end

  defp put_aws_config_value(opts, key) do
    case config(key) do
      nil -> opts
      value -> Keyword.put(opts, key, value)
    end
  end

  defp put_host_with_prefix(opts) do
    case config(:host) do
      nil -> opts
      host -> Keyword.put(opts, :host, "sns.#{config!(:region)}.#{host}")
    end
  end
end
