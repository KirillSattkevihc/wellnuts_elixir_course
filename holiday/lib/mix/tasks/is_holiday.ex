defmodule Mix.Tasks.IsHoliday do
  @moduledoc "The holiday mix task: `mix help is_holiday`"
  use Mix.Task

  @shortdoc "Simply calls the Holiday.is_holiday/0 function."
  def run(_) do
    Mix.Task.run("app.start")
    Holiday.init_db()

    if Holiday.is_holiday() == true do
      IO.puts("Yes")
    else
      IO.puts("No")
    end
  end
end
