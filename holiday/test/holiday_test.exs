defmodule HolidayTest do
  use ExUnit.Case
  doctest Holiday

  test "This is a holiday test" do
    db = Holiday.init_db()
    assert Holiday.is_holiday(db, ~D[2000-01-01]) == true
  end

  test "This isn't a holiday test" do
    db = Holiday.init_db()
    assert Holiday.is_holiday(db, ~D[2000-01-02]) == false
  end

  test "Time until holiday test" do
    db = Holiday.init_db()

    assert Holiday.time_until_holiday(db, :day, ~U[2020-11-12 14:22:27.157818Z]) ==
             42.40107638888889
  end

  test "Holiday test" do
    db = Holiday.init_db()
    assert Holiday.time_until_holiday(db, :day, ~U[2020-01-01 14:22:27.157818Z]) == 0
  end
end
