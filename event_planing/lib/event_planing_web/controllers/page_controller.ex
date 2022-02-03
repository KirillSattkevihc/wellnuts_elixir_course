defmodule EventPlaningWeb.PageController do
  use EventPlaningWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def entry(conn, _params) do
    render(conn, "account_view.html")
  end

  def login(conn, %{"password" => %{"pass" => pass}}) do
    case check_pass(pass) do
      true ->
        conn
        |> put_flash(:info, "welcome")
        |> put_session(:password, pass)
        |> redirect(to: Routes.page_path(conn, :index))

      false ->
        conn
        |> put_flash(:error, "try again")
        |> redirect(to: Routes.page_path(conn, :login))
    end
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: Routes.page_path(conn, :login))
  end

  def check_pass(pass) do
    if pass == "1234" do
      true
    else
      false
    end
  end
end
