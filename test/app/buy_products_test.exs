defmodule VendingMachine.BuyProductsTest do
  use VendingMachine.DataCase

  alias VendingMachine.BuyProducts

  import VendingMachine.AccountsFixtures
  import VendingMachine.ProductsFixtures

  describe "buy_product/1" do
    setup do
      user = user_fixture(deposit: 155, role: :buyer)
      seller = user_fixture(role: :seller)
      product = product_fixture(user_id: seller.id, cost: 50)
      %{user: user, product: product}
    end

    test "successful purchase", %{user: user, product: product} do
      amount_of_products = 2
      params = %{
        user_id: user.id,
        product_id: product.id,
        amount_of_products: amount_of_products
      }

      assert {
        :ok,
        %{
          updated_user: updated_user,
          updated_product: updated_product,
          total_spent: total_spent
        }
      } = BuyProducts.buy_product(params)

      assert updated_user.deposit == (user.deposit - (product.cost * amount_of_products))
      assert updated_product.amount_available == (product.amount_available - amount_of_products)
      assert total_spent == (amount_of_products * product.cost)
    end

    test "insufficient product availability", %{user: user, product: product} do
      params = %{
        user_id: user.id,
        product_id: product.id,
        amount_of_products: product.amount_available + 1
      }
      assert {:error, :validate_transaction, :exceeding_available_products} =
        BuyProducts.buy_product(params)
    end

    test "insufficient user deposit", %{product: product} do
      user = user_fixture(deposit: 0, role: :buyer)
      params = %{
        user_id: user.id,
        product_id: product.id,
        amount_of_products: 1
      }
      assert {:error, :validate_transaction, :insufficient_deposit} =
        BuyProducts.buy_product(params)
    end

    test "non-existent user or product", _context do
      params = %{user_id: -1, product_id: -1, amount_of_products: 1}
      assert {:error, :product_not_found} = BuyProducts.buy_product(params)
    end
  end
end
