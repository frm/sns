defmodule SNS.MixProject do
  use Mix.Project

  def project do
    [
      app: :sns,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:cowboy, ">= 2.0.0"},
      {:ex_aws, github: "avenueplace/ex_aws", tag: "2.4.1"},
      {:ex_aws_sns, "~> 2.3"},
      {:hackney, "~> 1.9"},
      {:jason, "~> 1.4"},
      {:plug, "~> 1.12"},
      {:plug_cowboy, ">= 2.0.0"}
    ]
  end
end