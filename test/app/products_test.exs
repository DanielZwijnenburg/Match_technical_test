defmodule VendingMachine.ProductsTest do
  use VendingMachine.DataCase

  alias VendingMachine.Products

  import VendingMachine.AccountsFixtures

  describe "create_product/1" do
    setup do
      %{user: user_fixture()}
    end

    test "requires user_id, name, amount_available and cost", %{user: _user} do
      {:error, changeset} = Products.create_product(%{})

      assert %{
        user_id: ["can't be blank"],
        name: ["can't be blank"],
        amount_available: ["can't be blank"],
        cost: ["can't be blank"]
      } = errors_on(changeset)
    end

    test "requires cost not to be negative", %{user: user} do
      {:error, changeset} = Products.create_product(%{user_id: user.id, cost: -1, name: "product name", amount_available: 1})

      assert %{cost: ["must be greater than 0"]} = errors_on(changeset)
    end

    test "requires amount_available not to be negative", %{user: user} do
      {:error, changeset} = Products.create_product(%{user_id: user.id, cost: 1, name: "product name", amount_available: -1})

      assert %{amount_available: ["must be greater than 0"]} = errors_on(changeset)
    end
  end
end
