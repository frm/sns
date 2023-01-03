defmodule SNS.API.Mock do
  @behaviour SNS.API

  alias SNS.Local.PubSub

  def subscribe(topic, _protocol, endpoint, opts \\ []) do
    name = Keyword.get(opts, :name, PubSub)

    PubSub.subscribe(name, topic, endpoint)
  end

  def confirm_subscription(_, _, _) do
    {:ok, :confirmed}
  end

  def publish(message, opts) do
    name = Keyword.get(opts, :name, PubSub)
    topic = Keyword.fetch!(opts, :topic_arn)

    PubSub.publish(name, topic, message)
  end
end
