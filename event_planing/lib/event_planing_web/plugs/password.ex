defmodule EventPlaningWeb.Plugs.Password do
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    user_pass = get_session(conn, :password)

    cond do
      EventPlaningWeb.PageController.check_pass(user_pass) == true ->
        assign(conn, :password, user_pass)

      true ->
        assign(conn, :password, nil)
    end
  end
end
