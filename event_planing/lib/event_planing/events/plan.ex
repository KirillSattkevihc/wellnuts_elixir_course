defmodule EventPlaning.Events.Plan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "plan" do
    field :date, :utc_datetime_usec
    field :repetition, :string, default: "week"

    timestamps()
  end

  @doc false
  def changeset(plan, attrs) do
    plan
    |> cast(attrs, [:date, :repetition])
    |> validate_required([:date, :repetition])
    |> validate_inclusion(:repetition, ["day", "week", "month", "year", "none"])
  end
end
