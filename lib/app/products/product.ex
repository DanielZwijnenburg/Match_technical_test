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
  end
end
