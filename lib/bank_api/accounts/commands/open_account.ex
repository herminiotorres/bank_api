defmodule BankAPI.Accounts.Commands.OpenAccount do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :account_uuid, Ecto.UUID
    field :initial_balance, :integer
  end

  def changeset(%__MODULE__{} = struct, params) do
    struct
    |> cast(params, [:account_uuid, :initial_balance])
    |> validate_required([:account_uuid, :initial_balance])
    |> validate_number(:initial_balance, greater_than: 0)
  end

  def valid?(command) do
    __struct__()
    |> changeset(Map.take(command, __schema__(:fields)))
    |> apply_action(:validate)
  end
end
