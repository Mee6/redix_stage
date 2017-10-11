defmodule RedixStage.Mixfile do
  use Mix.Project

  def project do
    [app: :redix_stage,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {RedixStage.Application, []}]
  end

  defp deps do
    [{:gen_stage, "~> 0.12.2"},
     {:plumbus, github: "cookkkie/plumbus"},
     {:redix, "~> 0.6.1"}]
  end
end
