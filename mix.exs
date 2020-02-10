defmodule Civile.MixProject do
  use Mix.Project

  def project do
    [
      app: :civile,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:riak_core, :logger],
      mod: {Civile, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:uniendo, git: "git://github.com/marianoguerra/uniendo.git", branch: "master"}
    ]
  end
end
