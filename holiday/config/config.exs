import Config

config :holiday, Holiday.Repo,
  database: "holiday_repo",
  username: "postgres",
  password: "123",
  hostname: "localhost"



config :holiday, ecto_repos: [Holiday.Repo]
