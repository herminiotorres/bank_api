defmodule BankAPI.Accounts.Events.AccountClosed do
  use Ecto.Schema

  @derive [Jason.Encoder]

  @primary_key false

  embedded_schema do
    field :account_uuid, Ecto.UUID
  end
end
