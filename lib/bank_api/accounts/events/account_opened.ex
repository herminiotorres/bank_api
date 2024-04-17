defmodule BankAPI.Accounts.Events.AccountOpened do
  use Ecto.Schema

  @derive [Jason.Encoder]

  @primary_key false

  embedded_schema do
    field :account_uuid, Ecto.UUID
    field :initial_balance, :integer
  end
end
