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
      Accounts.Projectors.AccountOpened
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
