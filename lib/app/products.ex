defmodule VendingMachine.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias VendingMachine.Repo
  alias VendingMachine.Products.Product

  def list_products() do
    Repo.all(Product)
  end

  def get_product(id), do: Repo.get(Product, id)
  def get_seller_product(id, user_id), do: Repo.get_by(Product, id: id, user_id: user_id)

  ## Product creation

  @doc """
  Creates a product.

  ## Examples

  iex> create_product(%{field: value})
  {:ok, %Product{}}

  iex> create_product(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """

  def create_product(attrs) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end
end
