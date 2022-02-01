defmodule Holiday.Holidays do
  use Ecto.Schema

  schema "holiday" do
    field(:name, :string)
    field(:holiday_date, :date)
  end
end
