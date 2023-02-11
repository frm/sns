defmodule SNS.Router do
  use Plug.Router

  import SNS.Config, only: [parse_config_value: 1]

  alias SNS.Callback
  alias SNS.Plug.Parsers.AwsJSON
  alias SNS.Verify

  # Plug.Router definitions
  # In case the user decides to forward all paths

  plug(Plug.Parsers,
    parsers: [:json, AwsJSON],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  post "/" do
    handle_request(conn)
  end

  match _ do
    not_found(conn)
  end

  # Internal API

  def call(conn, opts) do
    handler = Keyword.fetch!(opts, :handler)

    verify_with =
      Keyword.get(opts, :verify_with, false)
      |> parse_verify_with_value()

    conn = put_private(conn, :sns, handler: handler, verify_with: verify_with)

    if verify_with do
      # not being forwarded, called as part of `Plug.Router.post/4`.
      conn
      |> bypass_through_middleware()
      |> handle_request()
    else
      # being forwarded, just carry on
      super(conn, opts)
    end
  end

  defp bypass_through_middleware(conn) do
    Plug.run(conn, [
      {Plug.Parsers, [parsers: [:json, AwsJSON], json_decoder: Jason]}
    ])
  end

  defp handle_request(conn) do
    with %{"Type" => _type} <- conn.params,
         opts <- conn.private[:sns],
         true <- Verify.with(conn.params, opts[:verify_with]),
         {:ok, _} <- Callback.handle(conn.params, opts) do
      ok(conn)
    else
      _ -> bad_request(conn)
    end
  end

  defp parse_verify_with_value(false), do: false

  defp parse_verify_with_value({key, value}) do
    {key, parse_config_value(value)}
  end

  defp ok(conn) do
    send_resp(conn, 200, "")
  end

  defp not_found(conn) do
    send_resp(conn, 404, "not found")
  end

  defp bad_request(conn) do
    send_resp(conn, 400, "bad request")
  end
end
