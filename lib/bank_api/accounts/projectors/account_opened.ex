defmodule BankAPI.Accounts.Projectors.AccountOpened do
  use Commanded.Projections.Ecto,
    application: BankAPI.Accounts.Application,
    repo: BankAPI.Repo,
    consistency: :strong,
    name: "Accounts.Projectors.AccountOpened"

  alias BankAPI.Accounts.Events, as: E
  alias BankAPI.Accounts.Projections.Account

  project(%E.AccountOpened{} = evt, _metadata, fn multi ->
    Ecto.Multi.insert(multi, :account_opened, %Account{
      uuid: evt.account_uuid,
      current_balance: evt.initial_balance,
      status: Account.status().open
    })
  end)
end
