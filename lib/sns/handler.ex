defmodule SNS.Handler do
  @callback(handle(message :: binary) :: {:ok, term}, {:error, term})

  defmacro __using__(_) do
    quote do
      @behaviour SNS.Handler

      require Logger

      def handle(value) do
        Logger.info("SNS.SubscriptionHandler.handle/1: #{inspect(value)}")

        {:ok, value}
      end

      defoverridable handle: 1
    end
  end
end
