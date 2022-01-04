defmodule Joke do
  def get_joke() do
    case HTTPoison.get("https://joke.deno.dev") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        print_joke(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "joke_api Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  def print_joke(body) do

      body
      |> Jason.decode!()
      |> Map.values()
      |> Enum.map(fn x-> IO.puts(x) end)

  end
end
