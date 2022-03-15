defmodule EventPlaning.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user" do
    field :email, :string
    field :role, :string
    has_many :plan , EventPlaning.Events.Plan

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :role])
    |> validate_required([:email, :role])
    |> validate_inclusion(:role, ["admin", "user"])
  end
end
