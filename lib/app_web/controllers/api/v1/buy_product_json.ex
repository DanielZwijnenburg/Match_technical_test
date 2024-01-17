defmodule VendingMachineWeb.Api.V1.BuyProductJSON do
  alias VendingMachine.Products.Product
  alias VendingMachine.Accounts.User

  def show(%{user: user, product: product, change: change, total_spent: total_spent}) do
    %{
      data: %{
        user: data(user),
        product: data(product),
        change: change,
        total_spent: total_spent
      }
    }
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      role: user.role,
      deposit: user.deposit
    }
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
