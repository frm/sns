defmodule SNS.Subscription do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      @opts opts
      @topic Keyword.fetch!(opts, :topic)
      @endpoint Keyword.fetch!(opts, :endpoint)
      @protocol Keyword.fetch!(opts, :protocol)

      use Task, restart: :transient

      def start_link(args) do
        Task.start_link(__MODULE__, :run, [args])
      end

      def run(args) do
        options = Keyword.merge(@opts, args)
        topic = Keyword.fetch!(options, :topic)
        endpoint = Keyword.fetch!(options, :endpoint)
        protocol = Keyword.fetch!(options, :protocol)

        SNS.API.subscribe(topic, protocol, endpoint, options)
      end
    end
  end
end
