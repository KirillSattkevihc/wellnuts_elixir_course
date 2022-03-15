defmodule EventPlaning.Repo do
  use Ecto.Repo,
    otp_app: :event_planing,
    adapter: Ecto.Adapters.Postgres
end
