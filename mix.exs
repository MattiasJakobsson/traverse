defmodule Traverse.MixProject do
  use Mix.Project

  def project do
    [
      app: :traverse,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Traverse, []}
    ]
  end

  defp deps do
    [
      {:elixir_uuid, "~> 1.2"},
      {:poison, "~> 3.1"},
      {:quantum, "~> 2.3"},
      {:timex, "~> 3.0"},
      {:phoenix_pubsub, "~> 1.1.2"}
    ]
  end
end
