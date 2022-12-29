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

  post "/" do
    with %{"Type" => _type} <- conn.params,
         {:ok, _} <- Callback.handle(conn.params) do
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
