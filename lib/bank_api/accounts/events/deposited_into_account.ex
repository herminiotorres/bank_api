defmodule BankAPI.Accounts.Events.DepositedIntoAccount do
  use Ecto.Schema

  @derive [Jason.Encoder]

  @primary_key false

  embedded_schema do
    field :account_uuid, Ecto.UUID
    field :new_current_balance, :integer
  end
end
