defmodule Orbiter.Mixfile do
  use Mix.Project

  def project do
    [app: :orbiter,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end


  def application do
    [applications: apps,
     mod: {Orbiter, []}]
  end

  defp deps do
    case :os.type do
      {:unix, :linux} -> global_deps ++ linux_deps
      _other -> global_deps
    end
  end

  defp apps do
    case :os.type do
      {:unix, :linux} -> global_apps ++ linux_apps
      _other -> global_apps
    end
  end

  # Dependencies
  #----------------------------------------------------------------------

  defp global_deps do
    [
      {:lager, github: "basho/lager"},
      {:exlager, github: "khia/exlager"},
      {:extruder, github: "eloy/extruder"},
      {:poison, "~> 1.5"},
      {:msgpack, "~> 0.5.0"},
      {:hexate,  ">= 0.5.0"},
      {:cowboy, "~> 1.0.4"},
      {:plug, "~> 1.2.2"},
      {:distillery, "~> 0.9"}
    ]
  end

  defp global_apps do
    [:lager, :extruder, :cowboy, :plug, :ssl, :public_key, :hexate, :msgpack, :poison]
  end


  defp linux_deps do
    [{:elixir_ale, "~> 0.5.5"}]
  end

  defp linux_apps do
    [:elixir_ale]
  end


end
