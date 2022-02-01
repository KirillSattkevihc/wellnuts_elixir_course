defmodule Mix.Tasks.IsHoliday do
  @moduledoc "The holiday mix task: `mix help is_holiday`"
  use Mix.Task

  @shortdoc "Simply calls the Holiday.is_holiday/0 function."
  def run(_) do
    # This will start our application
    Mix.Task.run("app.start")
    db = Holiday.init_db()

    if Holiday.is_holiday(db) == true do
      IO.puts("Yes")
    else
      IO.puts("No")
    end
  end
end
