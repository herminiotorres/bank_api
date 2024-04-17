defmodule BankAPI.Accounts.Projectors.DepositsAndWithdrawals do
  use Commanded.Projections.Ecto,
    application: BankAPI.Accounts.Application,
    repo: BankAPI.Repo,
    consistency: :strong,
    name: "Accounts.Projectors.DepositsAndWithdrawals"

  alias BankAPI.Accounts
  alias BankAPI.Accounts.Events, as: E
  alias BankAPI.Accounts.Projections.Account
  alias Ecto.Changeset
  alias Ecto.Multi

  project(%E.DepositedIntoAccount{} = evt, _metadata, fn multi ->
    with {:ok, %Account{} = account} <- Accounts.get_account(evt.account_uuid) do
      Multi.update(
        multi,
        :account,
        Changeset.change(
          account,
          current_balance: evt.new_current_balance
        )
      )
    else
      # ignore when this happens
      _ -> multi
    end
  end)

  project(%E.WithdrawnFromAccount{} = evt, _metadata, fn multi ->
    with {:ok, %Account{} = account} <- Accounts.get_account(evt.account_uuid) do
      Multi.update(
        multi,
        :account,
        Changeset.change(
          account,
          current_balance: evt.new_current_balance
        )
      )
    else
      # ignore when this happens
      _ -> multi
    end
  end)
end
