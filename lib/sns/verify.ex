defmodule SNS.Verify do
  def with(_, false), do: true

  def with(params, {param, expected}) do
    case params do
      %{^param => ^expected} -> true
      _ -> false
    end
  end
end
