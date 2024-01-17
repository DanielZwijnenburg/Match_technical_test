defmodule VendingMachineWeb.Api.V1.UserController do
  use VendingMachineWeb, :controller

  alias VendingMachine.Accounts
  alias VendingMachineWeb.Api.V1.ChangesetJSON

  action_fallback VendingMachineWeb.Api.V1.FallbackController

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
          token = Accounts.create_user_api_token(user)
          conn
          |> put_status(:created)
          |> render(:show, user: user, token: token)
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_view(ChangesetJSON)
        |> put_status(:unprocessable_entity)
        |> render("error.json", changeset: changeset)
    end
  end
end
