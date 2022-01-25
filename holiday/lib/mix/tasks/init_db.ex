defmodule Mix.Tasks.InitDb do
  @moduledoc "The init DB mix task: `mix help init_db`"
  use Mix.Task

  @shortdoc "Simply calls the Holiday.init_db/0 function."
  def run(_) do
    Mix.Task.run("app.start")
    Holiday.init_db()
  end
end
