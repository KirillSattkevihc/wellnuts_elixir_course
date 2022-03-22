defmodule EventPlaning.Events.Plan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "plans" do
    field :name, :string
    field :date, :utc_datetime_usec
    field :repetition, :string, default: "week"

    timestamps()
  end

  @doc false
  def changeset(plans, attrs) do
    plans
    |> cast(attrs, [:name, :date, :repetition])
    |> validate_required([:name, :date, :repetition])
    |> validate_inclusion(:repetition, ["day", "week", "month", "year", "none"])
  end
end
