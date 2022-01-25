defmodule HolidayTest do
  use ExUnit.Case
  doctest Holiday

  test "This is a holiday test" do
    Holiday.init_db()
    assert Holiday.is_holiday( ~D[2022-01-01]) == true
  end

  test "This isn't a holiday test" do
    Holiday.init_db()
    assert Holiday.is_holiday( ~D[2022-01-02]) == false
  end

  test "Time until holiday test" do
    Holiday.init_db()
    assert Holiday.time_until_holiday(:day, ~U[2022-01-02 14:22:27.157818Z]) ==
      29.40107638888889
  end

  test "Holiday test" do
    Holiday.init_db()
    assert Holiday.time_until_holiday(:day, ~U[2022-01-01 14:22:27.157818Z]) == 0
  end
end
