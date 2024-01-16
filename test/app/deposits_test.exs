defmodule VendingMachine.DepositsTest do
  use VendingMachine.DataCase

  alias VendingMachine.Deposits

  import VendingMachine.AccountsFixtures

  describe "create_deposit/1" do
    setup do
      %{user: user_fixture()}
    end

    test "requires user_id, amount and coin_type", %{user: _user} do
      {:error, changeset} = Deposits.create_deposit(%{})

      assert %{
        user_id: ["can't be blank"],
        amount: ["can't be blank"],
        coin_type: ["can't be blank"]
      } = errors_on(changeset)
    end

    test "requires coin_type to be in the accepted list", %{user: user} do
      {:error, changeset} = Deposits.create_deposit(%{user_id: user.id, amount: 1, coin_type: 49})

      assert %{coin_type: ["is invalid"]} = errors_on(changeset)
    end

    test "requires amount not to be negative", %{user: user} do
      {:error, changeset} = Deposits.create_deposit(%{user_id: user.id, amount: -1, coin_type: 50})

      assert %{amount: ["must be greater than 0"]} = errors_on(changeset)
    end

    test "updates user amount", %{user: user} do
      %{id: user_id} = user
      {:ok, deposit} = Deposits.create_deposit(%{user_id: user_id, amount: 1, coin_type: 50})

      assert %{user_id: ^user_id} = deposit
      assert deposit.amount == 1
      assert deposit.coin_type == 50
    end
  end
end
