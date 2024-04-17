defmodule BankAPI.Accounts.Commands.WithdrawFromAccount do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :account_uuid, Ecto.UUID
    field :withdraw_amount, :integer
  end

  def changeset(%__MODULE__{} = struct, params) do
    struct
    |> cast(params, fields())
    |> validate_required(fields())
    |> validate_number(:withdraw_amount, greater_than: 0)
  end

  def valid?(command) do
    __struct__()
    |> changeset(Map.take(command, fields()))
    |> apply_action(:validate)
  end

  defp fields, do: __schema__(:fields)
end
