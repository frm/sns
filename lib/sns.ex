defmodule SNS do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts], location: :keep do
      @name Keyword.get(opts, :name, __MODULE__)
      @port opts[:port] || SNS.Config.config(:port, 8080)
      @scheme opts[:scheme] || SNS.Config.config(:scheme, :http)

      use Supervisor

      def start_link(args) do
        Supervisor.start_link(__MODULE__, args, name: @name)
      end

      @impl true
      def init(_args) do
        children = [{Plug.Cowboy, scheme: @scheme, plug: SNS.Router, options: [port: @port]}]

        opts = [strategy: :one_for_one, name: Module.concat(@name, Supervisor)]
        Supervisor.init(children, opts)
      end
    end
  end
end
