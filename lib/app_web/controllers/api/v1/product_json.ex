defmodule VendingMachineWeb.Api.V1.ProductJSON do
  alias VendingMachine.Products.Product

  def index(%{products: nil}) do
    %{data: []}
  end

  def index(%{products: products}) do
    %{data: for(product <- products, do: data(product))}
  end

  def show(%{product: product}) do
    %{data: data(product)}
  end

  defp data(%Product{} = product) do
    %{
      id: product.id,
      user_id: product.user_id,
      name: product.name,
      cost: product.cost,
      amount_available: product.amount_available
    }
  end
end
