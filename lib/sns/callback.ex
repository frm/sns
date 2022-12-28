defmodule SNS.Callback do
  alias SNS.Callback.Notification
  alias SNS.Callback.SubscriptionConfirmation

  def handle(%{"Type" => "SubscriptionConfirmation"} = params) do
    SubscriptionConfirmation.handle(params)
  end

  def handle(%{"Type" => "Notification"} = params) do
    Notification.handle(params)
  end
end
