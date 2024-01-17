defmodule VendingMachineWeb.Api.V1.BuyProductController do
  use VendingMachineWeb, :controller

  alias VendingMachine.{Deposits, BuyProducts}
  alias VendingMachineWeb.Api.V1.ChangesetJSON

  action_fallback VendingMachineWeb.Api.V1.FallbackController

  plug :only_allow_roles, %{roles: [:buyer]}

  def buy(conn, %{"buy_product" => buy_product_params}) do
    user_id = conn.assigns.current_user.id
    allowed_keys = ~w(user_id product_id amount_of_products)a

    params =
      buy_product_params
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
      |> Enum.filter(fn {k, _v} -> k in allowed_keys end)
      |> Map.new()
      |> Map.put_new(:user_id, user_id)

    case BuyProducts.buy_product(params) do
        {:ok, %{updated_user: updated_user, updated_product: updated_product, total_spent: total_spent}} ->
          change = Deposits.calculate_change(updated_user.deposit)
          {:ok, user} = Deposits.reset_deposits(updated_user)

          conn
          |> put_status(:created)
          |> render(:show, user: user, product: updated_product, change: change, total_spent: total_spent)
        {:error, :product_not_found} ->
          conn
          |> put_status(:not_found)
          |> json(%{errors: [%{status: 404, detail: "product not found"}]})
          |> halt()
        {:error, :user_not_found} ->
          conn
          |> put_status(:not_found)
          |> json(%{errors: [%{status: 404, detail: "user not found"}]})
          |> halt()
        {:error, :validate_transaction, reason} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: [%{status: 422, detail: reason}]})
          |> halt()
        {:error, :user_update_failed, changeset} ->
          conn
          |> put_view(ChangesetJSON)
          |> put_status(:unprocessable_entity)
          |> render("error.json", changeset: changeset)
        {:error, :product_update_failed, changeset} ->
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
