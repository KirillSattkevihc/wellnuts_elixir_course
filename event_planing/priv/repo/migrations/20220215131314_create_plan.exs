defmodule EventPlaning.Repo.Migrations.CreatePlans do
  use Ecto.Migration

  def change do
    create table(:plans) do
      add :name, :string
      add :date, :utc_datetime
      add :repetition, :string
      timestamps()
    end
  end
end
