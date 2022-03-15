defmodule EventPlaningWeb.Plugs.Password do
  import Plug.Conn

  import Ecto.Query
  alias EventPlaning.{Repo, Accounts.User}

  def init(_params) do
  end

  def call(conn, _params) do
    u_id = get_session(conn, :u_id)
    if is_nil(u_id)== false do
      assign(conn, :u_id, u_id)

    else
      assign(conn, :u_id, nil)
    end
  end
end
