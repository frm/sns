defmodule SNS.Config do
  @typep key :: atom
  @typep value :: term

  @spec config(key, value) :: value
  def config(key, default \\ nil) do
    get_env(key)
    |> parse_config(nil, default)
  end

  @spec config(key, key, value) :: value
  def config(key, param, default) do
    get_env(key)
    |> parse_config(param, default)
  end

  @spec config!(key, key) :: value
  def config!(key, param \\ nil) do
    get_env(key)
    |> parse_config!(param)
  end

  defp parse_config(nil, _, default) do
    default
  end

  defp parse_config(args, nil, _) do
    parse_config_value(args)
  end

  defp parse_config(args, param, default) do
    case Keyword.get(args, param) do
      nil -> default
      value -> parse_config_value(value)
    end
  end

  defp parse_config!(nil, param), do: raise("#{param} not set!")

  defp parse_config!(args, nil), do: parse_config_value!(args)

  defp parse_config!(args, param) do
    case Keyword.get(args, param) do
      nil -> raise("#{param} not set!")
      value -> parse_config_value!(value)
    end
  end

  defp get_env(key, default \\ nil), do: Application.get_env(:sns, key, default)

  defp parse_config_value({:system, var}), do: os_env(var)
  defp parse_config_value({m, f, a}), do: apply(m, f, a)
  defp parse_config_value(value), do: value

  defp parse_config_value!({:system, var}), do: os_env!(var)
  defp parse_config_value!({m, f, a}), do: apply(m, f, a)
  defp parse_config_value!(value), do: value

  defp os_env(name), do: System.get_env(name)

  defp os_env!(name) do
    case os_env(name) do
      nil -> raise "os env #{name} not set!"
      value -> value
    end
  end
end
