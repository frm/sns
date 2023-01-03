defmodule SNS.Router do
  use Plug.Router

  alias SNS.Callback
  alias SNS.Plug.Parsers.AwsJSON

  plug(Plug.Parsers,
    parsers: [:json, AwsJSON],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  def call(conn, opts) do
    handler = Keyword.fetch!(opts, :handler)
    conn = put_private(conn, :sns, handler: handler)

    super(conn, opts)
  end

  post "/" do
    with %{"Type" => _type} <- conn.params,
         opts <- conn.private[:sns],
         {:ok, _} <- Callback.handle(conn.params, opts) do
      send_resp(conn, 200, "")
    else
      _ ->
        send_resp(conn, 400, "bad request")
    end
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
