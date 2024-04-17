defmodule BankAPI.Accounts.Events.MoneyTransferRequested do
  use Ecto.Schema

  @derive [Jason.Encoder]

  @primary_key false

  embedded_schema do
    field :transfer_uuid, Ecto.UUID
    field :source_account_uuid, Ecto.UUID
    field :destination_account_uuid, Ecto.UUID
    field :amount, :integer
  end
end
