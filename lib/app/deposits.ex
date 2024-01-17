defmodule VendingMachine.Deposits do
  @moduledoc """
  The Deposits context.
  """

  import Ecto.Query, warn: false
  alias VendingMachine.Repo
  alias VendingMachine.Deposits.Deposit
  alias VendingMachine.Accounts
  alias VendingMachine.Accounts.User

  def allowed_coins do
    [5, 10, 20, 50, 100]
  end

  def list_deposits(user) do
    Repo.all(Deposit, user_id: user.id)
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

  def reset_deposits(%{id: user_id}) do
    query = from(d in Deposit, where: d.user_id == ^user_id)
    user = Accounts.get_user!(user_id)

    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(:delete_deposits, query)
    |> Ecto.Multi.update(:user, User.deposit_changeset(user, %{deposit: 0}))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  def calculate_change(deposit) when deposit > 0 do
    allowed_coins()
    |> Enum.reverse()
    |> Enum.reduce({deposit, %{}}, fn coin, {remaining, acc} ->
      if remaining >= coin do
        count = div(remaining, coin)
        new_remaining = rem(remaining, coin)
        {new_remaining, Map.put(acc, coin, count)}
      else
        {remaining, acc}
      end
    end)
    |> elem(1)
  end

  def calculate_change(_), do: %{}
end
