defmodule SNS.Plug.Parsers.AwsJSON do
  def init(opts), do: Plug.Parsers.JSON.init(opts)

  def parse(conn, "text", _, params, opts) do
    Plug.Parsers.JSON.parse(conn, "application", "json", params, opts)
  end

  def parse(conn, _type, _subtype, _params, _opts), do: {:next, conn}
end
