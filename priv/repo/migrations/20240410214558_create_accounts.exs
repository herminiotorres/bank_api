defmodule BankAPI.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :current_balance, :bigint

      timestamps type: :naive_datetime_usec
    end
  end
end
