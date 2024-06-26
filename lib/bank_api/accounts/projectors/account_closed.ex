defmodule BankAPI.Accounts.Projectors.AccountClosed do
  use Commanded.Projections.Ecto,
    application: BankAPI.Accounts.Application,
    repo: BankAPI.Repo,
    consistency: :strong,
    name: "Accounts.Projectors.AccountClosed"

  alias BankAPI.Accounts
  alias BankAPI.Accounts.Events, as: E
  alias BankAPI.Accounts.Projections.Account
  alias Ecto.Changeset
  alias Ecto.Multi

  project(%E.AccountClosed{} = evt, _metadata, fn multi ->
    with {:ok, %Account{} = account} <- Accounts.get_account(evt.account_uuid) do
      Multi.update(
        multi,
        :account,
        Changeset.change(account, status: Account.status().closed)
      )
    else
      # ignore when this happens
      _ -> multi
    end
  end)
end
