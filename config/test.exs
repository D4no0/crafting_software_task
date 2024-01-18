import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :crafting_software, CraftingSoftwareWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Nw6Tu8blFlgol3zn2pjEbVOVEqs7VwaKXfL+KTpP1N6SimMByYcv0Ebaw1CYAm/w",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
