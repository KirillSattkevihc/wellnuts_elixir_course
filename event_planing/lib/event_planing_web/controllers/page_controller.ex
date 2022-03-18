defmodule EventPlaningWeb.PageController do
  use EventPlaningWeb, :controller

  import Ecto.Query
  alias EventPlaning.{Repo, Accounts.User}

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def entry(conn, _params) do
    render(conn, "account_view.html")
  end

  def login(conn, %{"password" => %{"email" => email, "pass" => pass}}) do
    case check_account(email, pass) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "welcome")
        |> put_session(:user, user.id)
        |> redirect(to: Routes.page_path(conn, :index))

      :error ->
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

  def check_account(email, pass) do
    if pass == "1234" do
      query = from(m in User, where: m.email == ^email) |> Repo.one()

      if query != nil do
        {:ok, query}
      else
        :error
      end
    else
      :error
    end
  end
end
