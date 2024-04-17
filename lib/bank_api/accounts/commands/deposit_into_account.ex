defmodule BankAPI.Accounts.Commands.DepositIntoAccount do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :account_uuid, Ecto.UUID
    field :deposit_amount, :integer
    field :transfer_uuid, Ecto.UUID
  end

  def changeset(%__MODULE__{} = struct, params) do
    struct
    |> cast(params, fields())
    |> validate_required(fields())
    |> validate_number(:deposit_amount, greater_than: 0)
  end

  def valid?(command) do
    __struct__()
    |> changeset(Map.take(command, fields()))
    |> apply_action(:validate)
  end

  defp fields, do: __schema__(:fields)
end
