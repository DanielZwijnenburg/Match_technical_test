defmodule VendingMachineWeb.Api.V1.DepositController do
  use VendingMachineWeb, :controller

  alias VendingMachine.Deposits
  alias VendingMachineWeb.Api.V1.ChangesetJSON

  action_fallback VendingMachineWeb.FallbackController

  plug :only_allow_roles, roles: [:buyer]

  def index(conn, _params) do
    deposits = Deposits.list_deposits(conn.assigns[:current_user])

    render(conn, "index.json", deposits: deposits)
  end

  def create(conn, %{"deposit" => deposit_params}) do
    params =
      deposit_params
      |> Map.merge(%{"user_id" => conn.assigns[:current_user].id})

    case Deposits.create_deposit(params) do
      {:ok, deposit} ->
          conn
          |> put_status(:created)
          |> render(:show, deposit: deposit)
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_view(ChangesetJSON)
        |> put_status(:unprocessable_entity)
        |> render("error.json", changeset: changeset)
    end
  end

  defp only_allow_roles(%{assigns: %{current_user: current_user}} = conn, options) do
    if current_user.role in options[:roles] do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{errors: [%{status: 401, detail: "Only users with role: #{Enum.map(options[:roles], &Atom.to_string/1)} are allowed to access this endpoint"}]})
      |> halt()
    end
  end
end
