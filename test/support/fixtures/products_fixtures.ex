defmodule VendingMachine.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VendingMachine.Products` context.
  """

  def valid_product_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      user_id: -1,
      name: "product name",
      amount_available: 10,
      cost: 50
    })
  end

  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> valid_product_attributes()
      |> VendingMachine.Products.create_product()

    product
  end
end
