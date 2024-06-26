import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :bank_api, BankAPI.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "bank_api_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool_size: 10

config :bank_api, BankAPI.Accounts.Application,
  event_store: [
    adapter: Commanded.EventStore.Adapters.InMemory,
    serializer: Commanded.Serialization.JsonSerializer
  ]

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bank_api, BankAPIWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "fyo3VThtul+2RAPx4iQpjIULbQRhLe+U1L9hTkwPipSWC9qRsjI9zBwJpr58HwXu",
  server: false

# In test we don't send emails.
config :bank_api, BankAPI.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
