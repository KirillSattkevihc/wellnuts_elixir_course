defmodule EventPlaningWeb.PrivateController do
  use EventPlaningWeb, :controller

  plug :check_user

  def private(conn, _params) do
    render(conn, "index.html")
  end

  def check_user(conn, _params) do
    if conn.assigns[:password] do
      conn
    else
      conn
      |> put_flash(:error, "you don't logged")
      |> redirect(to: Routes.page_path(conn, :entry))
      |> halt()
    end
  end
end
