defmodule EventPlaning.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :role, :string
    has_many :plans, EventPlaning.Events.Plan

    timestamps()
  end

  @doc false
  def changeset(users, attrs) do
    users
    |> cast(attrs, [:email, :role])
    |> validate_required([:email, :role])
    |> validate_inclusion(:role, ["admin", "user"])
  end
end
