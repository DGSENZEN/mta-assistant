defmodule MtaExBackend.MixProject do
  use Mix.Project

  def project do
    [
      app: :mta_ex_backend,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: Mix.compilers(),
      protoc_opts: [
        "lib/gtfs-realtime.proto",
        out_dir: "lib/generated_protobufs"
      ]

    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools, :jason]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [

      {:phoenix, "~> 1.7.21"},
      {:plug_cowboy, "~> 2.5"},
      {:jason, "~> 1.4.4"},
      {:httpoison, "~> 2.0"},
      {:protobuf, "~> 0.14.1"},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
