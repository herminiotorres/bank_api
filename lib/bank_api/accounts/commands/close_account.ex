defmodule BankAPI.Accounts.Commands.CloseAccount do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :account_uuid, Ecto.UUID
  end

  def changeset(%__MODULE__{} = struct, params) do
    struct
    |> cast(params, fields())
    |> validate_required(fields())
  end

  def valid?(command) do
    __struct__()
    |> changeset(Map.take(command, fields()))
    |> apply_action(:validate)
  end

  defp fields, do: __schema__(:fields)
end
