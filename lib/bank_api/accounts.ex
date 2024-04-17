defmodule BankAPI.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias BankAPI.Accounts.Application
  alias BankAPI.Accounts.Commands, as: C
  alias BankAPI.Accounts.Projections.Account
  alias BankAPI.Repo

  def get_account(account_uuid) do
    case Repo.get(Account, account_uuid) do
      %Account{} = account ->
        {:ok, account}

      _reply ->
        {:error, :not_found}
    end
  end

  def open_account(%{"initial_balance" => initial_balance}) do
    account_uuid = Ecto.UUID.generate()

    dispatch_result =
      %C.OpenAccount{
        initial_balance: initial_balance,
        account_uuid: account_uuid
      }
      |> Application.dispatch(consistency: :strong)

    case dispatch_result do
      :ok ->
        {
          :ok,
          %Account{
            uuid: account_uuid,
            current_balance: initial_balance
          }
        }

      reply ->
        reply
    end
  end

  def open_account(_params), do: {:error, :bad_command}

  def deposit(account_uuid, amount) do
    dispatch_result =
      %C.DepositIntoAccount{
        account_uuid: account_uuid,
        deposit_amount: amount
      }
      |> Application.dispatch(consistency: :strong)

    case dispatch_result do
      :ok ->
        {
          :ok,
          Repo.get!(Account, account_uuid)
        }

      reply ->
        reply
    end
  end

  def withdraw(account_uuid, amount) do
    dispatch_result =
      %C.WithdrawFromAccount{
        account_uuid: account_uuid,
        withdraw_amount: amount
      }
      |> Application.dispatch(consistency: :strong)

    case dispatch_result do
      :ok ->
        {
          :ok,
          Repo.get!(Account, account_uuid)
        }

      reply ->
        reply
    end
  end

  def transfer(source_id, amount, destination_id) do
    %C.TransferBetweenAccounts{
      account_uuid: source_id,
      transfer_uuid: Ecto.UUID.generate(),
      transfer_amount: amount,
      destination_account_uuid: destination_id
    }
    |> Application.dispatch(consistency: :strong)
  end

  def close_account(account_uuid) do
    %C.CloseAccount{
      account_uuid: account_uuid
    }
    |> Application.dispatch(consistency: :strong)
  end
end
