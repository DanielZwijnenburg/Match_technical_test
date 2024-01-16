defmodule VendingMachineWeb.Api.V1.DepositJSON do
  alias VendingMachine.Deposits.Deposit

  def index(%{deposits: nil}) do
    %{data: []}
  end

  def index(%{deposits: deposits}) do
    %{data: for(deposit <- deposits, do: data(deposit))}
  end

  def show(%{deposit: deposit}) do
    %{data: data(deposit)}
  end

  defp data(%Deposit{} = deposit) do
    %{
      id: deposit.id,
      user_id: deposit.user_id,
      amount: deposit.amount,
      coin_type: deposit.coin_type
    }
  end
end
