defmodule VendingMachine.Repo.Migrations.CreateDeposits do
  use Ecto.Migration

  def change do
    create table(:deposits) do
      add(:user_id, references(:users), null: false)

      add(:amount, :integer, null: false)
      add(:coin_type, :integer, null: false)

      timestamps()
    end
  end
end
