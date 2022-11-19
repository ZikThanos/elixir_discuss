defmodule Discuss.AuthController do

  use DiscussWeb, :controller

  alias Discuss.{ Repo, User }

  plug Ueberauth

  @spec callback(
          %{:assigns => %{:ueberauth_auth => any, optional(any) => any}, optional(any) => any},
          any
        ) :: any
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_params = %{token: auth.credentials.token, email: auth.info.email, provider: "github"}
    changeset = User.changeset(%User{}, user_params)

    signin(conn, changeset)
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: Routes.topic_path(conn, :index))
  end

  defp signin(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:user_id, user.id)
        |> redirect(to: Routes.topic_path(conn, :index))
      {:fail, _reason} ->
        conn
        |> put_flash(:error, "Error signing in")
        |> redirect(to: Routes.topic_path(conn, :index))
    end

  end

  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil ->
        Repo.insert(changeset)
      user ->

        {:ok, user}
    end
  end
end
