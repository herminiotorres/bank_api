defmodule BankAPI.Accounts.Commands.TransferBetweenAccounts do
  use Ecto.Schema

  import Ecto.Changeset

  alias BankAPI.Repo
  alias BankAPI.Accounts.Projections.Account

  @primary_key false

  embedded_schema do
    field :account_uuid, Ecto.UUID
    field :transfer_uuid, Ecto.UUID
    field :transfer_amount, :integer
    field :destination_account_uuid, Ecto.UUID
  end

  def changeset(%__MODULE__{} = struct, params) do
    struct
    |> cast(params, fields())
    |> validate_required(fields())
  end

  def valid?(command) do
    cmd = Map.from_struct(command)

    with %Account{} <- account_exists?(cmd.destination_account_uuid),
         true <- account_open?(cmd.destination_account_uuid) do
      __struct__()
      |> changeset(Map.take(command, fields()))
      |> apply_action(:validate)
    else
      nil ->
        {:error, ["Destination account does not exist"]}

      false ->
        {:error, ["Destination account closed"]}

      reply ->
        reply
    end
  end

  defp account_exists?(uuid) do
    Repo.get(Account, uuid)
  end

  defp account_open?(uuid) do
    account = Repo.get!(Account, uuid)
    account.status == Account.status().open
  end

  defp fields, do: __schema__(:fields)
end
