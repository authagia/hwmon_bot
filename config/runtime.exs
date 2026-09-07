import Config

# IO.puts(:code.priv_dir(:hwmon_bot))
# env = Path.join([__DIR__, "config.toml"]) |> Enux.load

Path.join([:code.priv_dir(:hwmon_bot), "config.toml"]) |>
 IO.puts()
env = Path.join([:code.priv_dir(:hwmon_bot), "config.toml"]) |> Enux.load

config :hwmon_bot, env


# hexdocs.pm/enux/Enux.html
