defmodule EventPlaning.Repo.Migrations.CreatePlan do
  use Ecto.Migration

  def change do
    create table(:plan) do
      add :name, :string
      add :date, :utc_datetime
      add :repetition, :string
      add :user_id, references(:user, on_delete: :delete_all)

      timestamps()
    end

    create(index(:plan, [:user_id]))
  end
end
