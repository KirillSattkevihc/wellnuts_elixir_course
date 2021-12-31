defmodule Joke do
  def get_joke() do
    case HTTPoison.get("https://github.com/UltiRequiem/joke") do
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
    url =
      body
      |> Floki.find("a")
      |> Floki.attribute("href")
      |> Enum.find( fn x -> x == "https://joke.deno.dev" end)
      |> to_string()
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
         print_joke(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "joke_api Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
    {:ok, %HTTPoison.Response{status_code: 404}} ->
      IO.puts "GitHub not found :("
    {:error, %HTTPoison.Error{reason: reason}} ->
      IO.inspect reason
    end
  end

  def print_joke(body) do
    output=
      body
      |> Jason.decode!()
      |> Map.values()
      |> Enum.map(fn x-> IO.puts(x) end)
    output
  end
end
