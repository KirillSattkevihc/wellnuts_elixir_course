defmodule EventPlaning.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :role, :string, null: false
      timestamps()
    end

    create(unique_index(:users, [:email]))
  end
end
