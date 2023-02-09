defmodule SNS.Subscription do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      @opts opts

      use Task, restart: :transient

      import SNS.Config, only: [parse_config_value!: 1]

      def start_link(args) do
        Task.start_link(__MODULE__, :run, [args])
      end

      def run(args) do
        options = Keyword.merge(@opts, args)
        topic = Keyword.fetch!(options, :topic) |> parse_config_value!()
        endpoint = Keyword.fetch!(options, :endpoint) |> parse_config_value!()
        protocol = Keyword.fetch!(options, :protocol) |> parse_config_value!()

        SNS.API.subscribe(topic, protocol, endpoint, options)
      end
    end
  end
end
