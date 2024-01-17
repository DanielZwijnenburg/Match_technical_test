defmodule VendingMachine.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add(:user_id, references(:users), null: false)

      add(:amount_available, :integer, null: false)
      add(:cost, :integer, null: false)
      add(:name, :string, null: false)

      timestamps()
    end
  end
end
