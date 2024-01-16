defmodule VendingMachine.Deposits.Deposit do
  use Ecto.Schema
  import Ecto.Changeset

  alias VendingMachine.Deposits
  alias VendingMachine.Accounts.User

  schema "deposits" do
    belongs_to(:user, User)

    field :amount, :integer
    field :coin_type, :integer

    timestamps(type: :utc_datetime)
  end

  def changeset(deposit, attrs) do
    deposit
    |> cast(
      attrs,
      [
        :user_id,
        :amount,
        :coin_type
      ]
    )
    |> validate_required([
      :user_id,
      :amount,
      :coin_type
    ])
    |> validate_inclusion(:coin_type, Deposits.allowed_coins())
    |> validate_number(:amount, greater_than: 0)
  end
end
