defmodule BankAPI.Accounts.Supervisor do
  use Supervisor

  alias BankAPI.Accounts

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg)
  end

  @impl true
  def init(_init_arg) do
    children = [
      Accounts.Application,
      # Projectors
      Accounts.Projectors.AccountOpened,
      Accounts.Projectors.AccountClosed,
      Accounts.Projectors.DepositsAndWithdrawals,
      # Process managers
      Accounts.ProcessManagers.TransferMoney
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
