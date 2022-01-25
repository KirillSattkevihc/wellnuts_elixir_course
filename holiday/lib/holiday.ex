defmodule Holiday do
  import Ecto.Query
  alias Holiday.{Holidays, Repo}
  @moduledoc """
  Documentation for `Holiday`.
  """

  @doc """
  Holiday.init_db():: atom()` - returns holidays database

  ## Examples
      iex> Holiday.init_db
      :ok

  """

  @spec init_db() :: list()
  def init_db() do
    Holiday.Repo.delete_all(Holidays)
    db = File.read!("us-california-nonworkingdays.ics")
    |> ICalendar.from_ics()
    |> Stream.map(fn x-> %{name: x.summary,date: Date.new!(Date.utc_today.year, x.dtstart.month, x.dtstart.day)} end)
    |> Enum.each(fn x-> Ecto.Changeset.change(%Holiday.Holidays{},%{name: x.name, holiday_date: x.date})|> Holiday.Repo.insert() end )
    end

  @doc """
  Holiday.is_holiday( Calendar.datetime()) :: boolean()`

    Returns true if today is a holiday, and false it it's not.

  ## Examples
    iex> Holiday.init_db
    iex> Holiday.is_holiday(~U[2020-04-25 15:38:22Z])
    false

  """

  @spec is_holiday( Calendar.datetime()) :: boolean()
  def is_holiday( day \\ Date.utc_today()) do
    q= from(x in Holidays, select: x.holiday_date)|>Repo.all()
    Enum.any?(q, fn x -> x==day end)
  end

  @doc """
  Holiday.time_until_holiday( atom(), Calendar.datetime()) :: float()

  Arg `unit` is `:day`, `:hour`, `:minute` or `:second`.

  Should return a float representing a number of `unit`s till closest holiday in the future.

  ## Examples
      iex> Holiday.init_db
      iex> Holiday.time_until_holiday(:day, ~U[2022-01-01 15:38:22Z])
      0

      iex> Holiday.init_db
      iex> Holiday.time_until_holiday(:day, ~U[2022-01-02 15:38:22Z])
      29.34835648148148

  """

  @spec time_until_holiday(atom(), Calendar.datetime()) :: float()
  def time_until_holiday(unit, now \\ DateTime.utc_now()) do
    if is_holiday(DateTime.to_date(now)) == true do
      0
    else
      holiday = from(m in Holidays, where: m.holiday_date>^Date.utc_today, select: min(m.holiday_date))
      |> Repo.one()
      |> NaiveDateTime.new!(~T[00:00:00])
      |> DateTime.from_naive!("Etc/UTC")

      unit_w = %{
        day: 3600 * 24,
        hour: 3600,
        minute: 60,
        second: 1
      }

      time_until_holiday= DateTime.diff(holiday, now)
      result= time_until_holiday/Map.get(unit_w, unit)
    end
  end
end
