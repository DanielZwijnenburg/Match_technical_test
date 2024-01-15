defmodule VendingMachine.Deposits do
  @moduledoc """
  The Deposits context.
  """

  alias VendingMachine.Repo
  alias VendingMachine.Deposits.Deposit
  alias VendingMachine.Accounts.User

  def allowed_coins do
    [5, 10, 20, 50, 100]
  end

  ## Deposit creation

  @doc """
  Creates a deposit.

  ## Examples

  iex> create_deposit(%{field: value})
  {:ok, %Deposit{}}

  iex> create_deposit(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """

  def create_deposit(attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:deposit, Deposit.changeset(%Deposit{}, attrs))
    |> Ecto.Multi.run(:update_user, &update_user_deposit/2)
    |> Repo.transaction()
    |> case do
      {:ok, %{deposit: deposit}} -> {:ok, deposit}
      {:error, :deposit, changeset, _} -> {:error, changeset}
    end
  end

  defp update_user_deposit(repo, %{deposit: deposit}) do
    case repo.get(User, deposit.user_id) do
      nil ->
        {:error, :user_not_found}
      user ->
        new_deposit = user.deposit + (deposit.amount * deposit.coin_type)

        user
        |> User.deposit_changeset(%{deposit: new_deposit})
        |> repo.update()
    end
  end
end
