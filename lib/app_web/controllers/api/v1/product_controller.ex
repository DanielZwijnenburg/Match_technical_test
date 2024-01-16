defmodule VendingMachineWeb.Api.V1.ProductController do
  use VendingMachineWeb, :controller

  alias VendingMachine.Products
  alias VendingMachine.Products.Product
  alias VendingMachineWeb.Api.V1.ChangesetJSON

  action_fallback VendingMachineWeb.Api.V1.FallbackController

  plug :only_allow_roles, %{roles: [:seller]} when action in [:create, :update]

  def index(conn, _params) do
    products = Products.list_products()

    render(conn, "index.json", products: products)
  end

  def create(conn, %{"product" => product_params}) do
    params =
      product_params
      |> Map.merge(%{"user_id" => conn.assigns[:current_user].id})

    case Products.create_product(params) do
      {:ok, product} ->
        conn
        |> put_status(:created)
        |> render(:show, product: product)
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_view(ChangesetJSON)
        |> put_status(:unprocessable_entity)
        |> render("error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    product = Products.get_product(id)

    if product do
      render(conn, "show.json", product: product)
    else
      {:error, :not_found}
    end
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Products.get_product(id)

    with {:ok, %Product{} = product} <- Products.update_product(product, product_params) do
      render(conn, :show, product: product)
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
