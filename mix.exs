defmodule Languages.Mixfile do
  use Mix.Project

  def project do
    [app: :languages,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps,
     aliases: aliases]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{ :poison, "~> 1.4.0" }]
  end

  defp aliases do
    ## force compilation because it's not tracking updates to the json files
    [{:"compile", ["compile --force"]}]
  end
end
