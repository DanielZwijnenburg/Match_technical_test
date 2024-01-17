defmodule VendingMachine.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  alias VendingMachine.Accounts.User

  schema "products" do
    belongs_to(:user, User)

    field :name, :string
    field :amount_available, :integer
    field :cost, :integer

    timestamps(type: :utc_datetime)
  end

  def changeset(product, attrs) do
    product
    |> cast(
      attrs,
      [
        :user_id,
        :name,
        :amount_available,
        :cost
      ]
    )
    |> validate_required([
        :user_id,
        :name,
        :amount_available,
        :cost
    ])
    |> validate_number(:cost, greater_than: 0)
    |> validate_number(:amount_available, greater_than: 0)
    |> validate_multiple_of(:cost, VendingMachine.Deposits.allowed_coins())
  end

  defp validate_multiple_of(changeset, field, allowed_multiples) do
    validate_change(changeset, field, fn _, value ->
      case is_multiple_of(value, allowed_multiples) do
        true -> []
        false -> [{field, "must be a multiple of #{Enum.join(allowed_multiples, ", ")}"}]
      end
    end)
  end

  defp is_multiple_of(value, multiples) when is_integer(value) do
    Enum.any?(multiples, fn multiple -> rem(value, multiple) == 0 end)
  end
  defp is_multiple_of(_value, _multiples), do: false
end
