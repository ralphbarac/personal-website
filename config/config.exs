# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :website,
  ecto_repos: [Website.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :website, WebsiteWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: WebsiteWeb.ErrorHTML, json: WebsiteWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Website.PubSub,
  live_view: [signing_salt: "ARKH9jxF"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :website, Website.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  website: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  website: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# RSS Feed Configuration
config :website, :rss,
  title: "Ralph Barac's Blog",
  description:
    "Thoughts, tutorials, and insights about software development, technology, and continuous learning",
  max_items: 20,
  # 1 hour
  cache_ttl: 3600,
  language: "en-us",
  # Update with actual email
  managing_editor: "ralph@ralphbarac.com",
  # Update with actual email
  webmaster: "ralph@ralphbarac.com"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
