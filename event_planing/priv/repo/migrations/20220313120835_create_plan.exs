defmodule EventPlaning.Repo.Migrations.CreatePlans do
  use Ecto.Migration

  def change do
    create table(:plans) do
      add :name, :string
      add :date, :utc_datetime
      add :repetition, :string
      add :users_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create(index(:plans, [:users_id]))
  end
end
