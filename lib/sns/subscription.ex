defmodule SNS.Subscription do
  defmacro __using__(_) do
    quote location: :keep do
      use Task, restart: :transient

      import SNS.Config, only: [parse_config_value!: 1]

      def start_link(opts) do
        Task.start_link(__MODULE__, :run, [opts])
      end

      def run(opts) do
        topic = Keyword.fetch!(opts, :topic) |> parse_config_value!()
        endpoint = Keyword.fetch!(opts, :endpoint) |> parse_config_value!()
        protocol = Keyword.fetch!(opts, :protocol) |> parse_config_value!()

        SNS.API.subscribe(topic, protocol, endpoint, opts)
      end
    end
  end
end
