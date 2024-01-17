defmodule VendingMachine.BuyProducts do
  @moduledoc """
  The BuyProducts context.
  """

  import Ecto.Query, warn: false
  alias VendingMachine.Repo
  alias VendingMachine.Products.Product
  alias VendingMachine.Accounts.User

  def buy_product(%{user_id: user_id, product_id: product_id, amount_of_products: amount_of_products}) do
    multi_transaction =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:get_product, fn repo, _ ->
        get_product(product_id, repo)
      end)
      |> Ecto.Multi.run(:get_user, fn repo, _ ->
        get_user(user_id, repo)
      end)
      |> Ecto.Multi.run(:validate_transaction, fn _repo, %{get_product: product, get_user: user} ->
        validate_transaction(product, user, amount_of_products)
      end)
      |> Ecto.Multi.run(:update_user, fn _, %{validate_transaction: %{user_changeset: user_changeset}} ->
        update_resource(user_changeset)
      end)
      |> Ecto.Multi.run(:update_product, fn _, %{validate_transaction: %{product_changeset: product_changeset}} ->
        update_resource(product_changeset)
      end)
    case Repo.transaction(multi_transaction) do
      {:ok, %{update_user: updated_user, update_product: updated_product, validate_transaction: %{total_spent: total_spent}}} ->
        {:ok, %{updated_user: updated_user, updated_product: updated_product, total_spent: total_spent}}

      {:error, :get_product, :not_found, _} ->
        {:error, :product_not_found}

      {:error, :get_user, :not_found, _} ->
        {:error, :user_not_found}

      {:error, :validate_transaction, reason, _} ->
        {:error, :validate_transaction, reason}

      {:error, :update_user, changeset, _} ->
        {:error, :user_update_failed, changeset}

      {:error, :update_product, changeset, _} ->
        {:error, :product_update_failed, changeset}
    end
  end

  defp get_product(product_id, repo) do
    case repo.get(Product, product_id) do
      nil -> {:error, :not_found}
      product -> {:ok, product}
    end
  end

  defp get_user(user_id, repo) do
    case repo.get(User, user_id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  defp validate_transaction(product, user, amount_of_products) do
    new_amount_available = product.amount_available - amount_of_products
    total_spent = product.cost * amount_of_products
    new_deposit = user.deposit - total_spent

    cond do
      new_amount_available < 0 ->
        {:error, :exceeding_available_products}

      new_deposit < 0 ->
        {:error, :insufficient_deposit}

      true ->
        user_changeset = Ecto.Changeset.change(user, deposit: new_deposit)
        product_changeset = Ecto.Changeset.change(product, amount_available: new_amount_available)
        { :ok,
          %{
            user_changeset: user_changeset,
            product_changeset: product_changeset,
            total_spent: total_spent
          }
        }
    end
  end

  defp update_resource(changeset) do
    case Repo.update(changeset) do
      {:ok, resource} -> {:ok, resource}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
