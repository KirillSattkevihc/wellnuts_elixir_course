defmodule EventPlaningWeb.Plugs.Password do
  import Plug.Conn

  import Ecto.Query
  alias EventPlaning.{Accounts, Repo, Accounts.User}

  def init(_params) do
  end

  def call(conn, _params) do
    u_id = get_session(conn, :user)

    if is_nil(u_id) do
      assign(conn, :user_info, nil)
    else
      case Accounts.get_user(u_id) do
        %User{} = user ->
          assign(conn, :user_info, user)

        nil ->
          assign(conn, :user_info, nil)
      end
    end
  end
end
