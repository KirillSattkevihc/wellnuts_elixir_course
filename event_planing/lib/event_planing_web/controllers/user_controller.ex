defmodule EventPlaningWeb.UserController do
  use EventPlaningWeb, :controller
  alias EventPlaning.Accounts
  alias EventPlaning.Accounts.User

  def index(conn, _params) do
    user_info = conn.assigns[:user_info]

    if user_info.role == "admin" do
      user = Accounts.list_user()
      render(conn, "index.html", user: user)
    else
      conn
      |> put_flash(:error, "you aren't admin")
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome to the club, body.")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user(id)

    if Ability.can?(user, :show, conn.assigns[:user_info]) do
      render(conn, "show.html", user: user)
    else
      conn
      |> put_flash(:info, "Your abilities aren't strong")
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user(id)

    if Ability.can?(user, :update, conn.assigns[:user_info]) do
      changeset = Accounts.change_user(user)
      render(conn, "edit.html", user: user, changeset: changeset)
    else
      conn
      |> put_flash(:info, "Your abilities aren't strong")
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user(id)

    if Ability.can?(user, :delete, conn.assigns[:user_info]) do
      {:ok, _user} = Accounts.delete_user(user)

      conn
      |> put_flash(:info, "User deleted successfully.")
      |> redirect(to: Routes.user_path(conn, :index))
    else
      conn
      |> put_flash(:info, "Your abilities aren't strong")
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
