defmodule BankAPI.Router do
  use Commanded.Commands.Router

  alias BankAPI.Accounts.Aggregates.Account
  alias BankAPI.Accounts.Commands.OpenAccount
  alias BankAPI.Accounts.Commands.CloseAccount
  alias BankAPI.Accounts.Commands.DepositIntoAccount
  alias BankAPI.Accounts.Commands.WithdrawFromAccount
  alias BankAPI.Accounts.Commands.TransferBetweenAccounts

  middleware(BankApi.Support.Middleware.ValidateCommand)

  dispatch(OpenAccount, to: Account, identity: :account_uuid)
  dispatch(CloseAccount, to: Account, identity: :account_uuid)
  dispatch(DepositIntoAccount, to: Account, identity: :account_uuid)
  dispatch(WithdrawFromAccount, to: Account, identity: :account_uuid)
  dispatch(TransferBetweenAccounts, to: Account, identity: :account_uuid)
end
