defmodule BankAPIWeb.AccountJSON do
  alias BankAPI.Accounts.Projections.Account

  @doc """
  Renders a list of accounts.
  """
  def index(%{accounts: accounts}) do
    %{data: for(account <- accounts, do: data(account))}
  end

  @doc """
  Renders a single account.
  """
  def show(%{account: account}) do
    %{data: data(account)}
  end

  def account(%{account: account}) do
    if account.status == Account.status().closed do
      %{
        uuid: account.uuid,
        current_balance: account.current_balance
      }
    else
      %{
        uuid: account.uuid,
        current_balance: account.current_balance,
        status: account.status
      }
    end
  end

  defp data(%Account{} = account) do
    %{
      uuid: account.uuid,
      current_balance: account.current_balance,
      inserted_at: account.inserted_at,
      updated_at: account.updated_at
    }
  end
end
