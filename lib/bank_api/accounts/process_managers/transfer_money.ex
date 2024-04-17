defmodule BankAPI.Accounts.ProcessManagers.TransferMoney do
  use Commanded.ProcessManagers.ProcessManager,
    name: "Accounts.ProcessManagers.TransferMoney",
    application: BankAPI.Accounts.Application

  use Ecto.Schema

  alias __MODULE__
  alias BankAPI.Accounts.Commands, as: C
  alias BankAPI.Accounts.Events, as: E

  @derive [Jason.Encoder]

  @primary_key false

  embedded_schema do
    field :transfer_uuid, Ecto.UUID
    field :source_account_uuid, Ecto.UUID
    field :destination_account_uuid, Ecto.UUID
    field :amount, :integer
    field :status, :string
  end

  def interested?(%E.MoneyTransferRequested{transfer_uuid: transfer_uuid}),
    do: {:start!, transfer_uuid}

  def interested?(%E.WithdrawnFromAccount{account_uuid: transfer_uuid})
      when is_nil(transfer_uuid),
      do: false

  def interested?(%E.WithdrawnFromAccount{account_uuid: transfer_uuid}),
    do: {:continue!, transfer_uuid}

  def interested?(%E.DepositedIntoAccount{account_uuid: transfer_uuid})
      when is_nil(transfer_uuid),
      do: false

  def interested?(%E.DepositedIntoAccount{account_uuid: transfer_uuid}),
    do: {:stop, transfer_uuid}

  def interested?(_event), do: false

  def handle(%TransferMoney{}, %E.MoneyTransferRequested{
        source_account_uuid: source_account_uuid,
        amount: transfer_amount,
        transfer_uuid: transfer_uuid
      }) do
    %C.WithdrawFromAccount{
      account_uuid: source_account_uuid,
      withdraw_amount: transfer_amount,
      transfer_uuid: transfer_uuid
    }
  end

  def handle(
        %TransferMoney{transfer_uuid: transfer_uuid} = pm,
        %E.WithdrawnFromAccount{transfer_uuid: transfer_uuid}
      ) do
    %C.DepositIntoAccount{
      account_uuid: pm.destination_account_uuid,
      deposit_amount: pm.amount,
      transfer_uuid: pm.transfer_uuid
    }
  end

  def apply(%TransferMoney{} = pm, %E.MoneyTransferRequested{} = evt) do
    %TransferMoney{
      pm
      | transfer_uuid: evt.transfer_uuid,
        source_account_uuid: evt.source_account_uuid,
        destination_account_uuid: evt.destination_account_uuid,
        amount: evt.amount,
        status: :withdraw_money_from_source_account
    }
  end

  def apply(%TransferMoney{} = pm, %E.WithdrawnFromAccount{}) do
    %TransferMoney{
      pm
      | status: :deposit_money_in_destination_account
    }
  end
end
