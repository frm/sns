defmodule SNS.Callback do
  alias SNS.Callback.Notification
  alias SNS.Callback.SubscriptionConfirmation

  def handle(%{"Type" => "SubscriptionConfirmation"} = params, opts) do
    SubscriptionConfirmation.handle(params, opts)
  end

  def handle(%{"Type" => "Notification"} = params, opts) do
    Notification.handle(params, opts)
  end
end
