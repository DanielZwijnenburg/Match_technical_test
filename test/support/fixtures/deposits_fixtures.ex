defmodule VendingMachine.DepositsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VendingMachine.Deposits` context.
  """

  def valid_deposit_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      user_id: -1,
      amount: 5,
      coin_type: 50
    })
  end

  def deposit_fixture(attrs \\ %{}) do
    {:ok, deposit} =
      attrs
      |> valid_deposit_attributes()
      |> VendingMachine.Deposits.create_deposit()

    deposit
  end
end
