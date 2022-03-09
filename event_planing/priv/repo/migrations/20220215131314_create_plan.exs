defmodule EventPlaning.Repo.Migrations.CreatePlan do
  use Ecto.Migration

  def change do
    create table(:plan) do
      add :name, :string
      add :date, :utc_datetime
      add :repetition, :string

      timestamps()
    end
  end
end
