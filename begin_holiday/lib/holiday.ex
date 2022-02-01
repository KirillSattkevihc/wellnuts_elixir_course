defmodule Holiday do
  @moduledoc """
  Documentation for `Holiday`.
  """

  @doc """
  Holiday.init_db():: list()` - returns holidays database

  ## Examples

      iex> Holiday.init_db

  """

  @spec init_db() :: list()
  def init_db() do
    File.read!("us-california-nonworkingdays.ics") |> ICalendar.from_ics()
  end

  @doc """
  Holiday.is_holiday(list(), Calendar.datetime()) :: boolean()`

  First arg is result of calling `init_db()`.

  Returns true if today is a holiday, and false it it's not.

  ## Examples
      iex> db= Holiday.init_db
      iex> Holiday.is_holiday(db, ~U[2020-04-25 15:38:22Z])
      false

  """

  @spec is_holiday(list(), Calendar.datetime()) :: boolean()
  def is_holiday(db, day \\ Date.utc_today()) do
    Enum.any?(db, fn x -> x.dtstart.day == day.day and x.dtstart.month == day.month end)
  end

  @doc """
  Holiday.time_until_holiday(list(), atom(), Calendar.datetime()) :: float()

  Arg `unit` is `:day`, `:hour`, `:minute` or `:second`.
  First arg is result of calling `init_db()`.
  Should return a float representing a number of `unit`s till closest holiday in the future.

  ## Examples
      iex> db= Holiday.init_db
      iex> Holiday.time_until_holiday(db, :day, ~U[2020-01-01 15:38:22Z])
      0

      iex> db= Holiday.init_db
      iex> Holiday.time_until_holiday(db, :day, ~U[2020-01-02 15:38:22Z])
      29.34835648148148

  """
  @unit_w %{day: 3600 * 24, hour: 3600, minute: 60, second: 1}
  @spec time_until_holiday(list(), atom(), Calendar.datetime()) :: float()
  def time_until_holiday(db, unit, now \\ DateTime.utc_now()) do
    if is_holiday(db, DateTime.to_date(now)) == true do
      0
    else
      db_now =
        Enum.map(db, fn x ->
          if now.month < x.dtstart.month or
               (now.month == x.dtstart.month and now.day < x.dtstart.day) do
            Date.new!(now.year, x.dtstart.month, x.dtstart.day)
            |> NaiveDateTime.new!(~T[00:00:00])
            |> DateTime.from_naive!("Etc/UTC")
          else
            Date.new!(now.year + 1, x.dtstart.month, x.dtstart.day)
            |> NaiveDateTime.new!(~T[00:00:00])
            |> DateTime.from_naive!("Etc/UTC")
          end
        end)

      time_until_holiday =
        db_now
        |> Enum.map(fn x -> DateTime.diff(x, now) end)
        |> Enum.min()

      time_until_holiday / Map.get(@unit_w, :day)
    end
  end
end
