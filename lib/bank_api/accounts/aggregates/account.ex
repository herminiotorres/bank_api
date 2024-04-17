defmodule BankAPI.Accounts.Aggregates.Account do
  use Ecto.Schema

  @primary_key false

  embedded_schema do
    field :uuid, Ecto.UUID
    field :current_balance, :integer
    field :closed?, :boolean, default: false
  end

  alias __MODULE__
  alias BankAPI.Accounts.Commands, as: C
  alias BankAPI.Accounts.Events, as: E

  def execute(
        %Account{uuid: nil},
        %C.OpenAccount{
          account_uuid: account_uuid,
          initial_balance: initial_balance
        }
      )
      when initial_balance > 0 do
    %E.AccountOpened{
      account_uuid: account_uuid,
      initial_balance: initial_balance
    }
  end

  def execute(
        %Account{uuid: nil},
        %C.OpenAccount{
          initial_balance: initial_balance
        }
      )
      when initial_balance <= 0 do
    {:error, :initial_balance_must_be_above_zero}
  end

  def execute(%Account{}, %C.OpenAccount{}) do
    {:error, :account_already_opened}
  end

  def execute(
        %Account{uuid: account_uuid, closed?: true},
        %C.CloseAccount{
          account_uuid: account_uuid
        }
      ) do
    {:error, :account_already_closed}
  end

  def execute(
        %Account{uuid: account_uuid, closed?: false},
        %C.CloseAccount{
          account_uuid: account_uuid
        }
      ) do
    %E.AccountClosed{
      account_uuid: account_uuid
    }
  end

  def execute(
        %Account{},
        %C.CloseAccount{}
      ) do
    {:error, :not_found}
  end

  def execute(
        %Account{uuid: account_uuid, closed?: false, current_balance: current_balance},
        %C.DepositIntoAccount{account_uuid: account_uuid, deposit_amount: amount}
      ) do
    %E.DepositedIntoAccount{
      account_uuid: account_uuid,
      new_current_balance: current_balance + amount
    }
  end

  def execute(
        %Account{uuid: account_uuid, closed?: true},
        %C.DepositIntoAccount{account_uuid: account_uuid}
      ) do
    {:error, :account_closed}
  end

  def execute(
        %Account{},
        %C.DepositIntoAccount{}
      ) do
    {:error, :not_found}
  end

  def execute(
        %Account{uuid: account_uuid, closed?: false, current_balance: current_balance},
        %C.WithdrawFromAccount{account_uuid: account_uuid, withdraw_amount: amount}
      ) do
    if current_balance - amount > 0 do
      %E.WithdrawnFromAccount{
        account_uuid: account_uuid,
        new_current_balance: current_balance - amount
      }
    else
      {:error, :insufficient_funds}
    end
  end

  def execute(
        %Account{uuid: account_uuid, closed?: true},
        %C.WithdrawFromAccount{account_uuid: account_uuid}
      ) do
    {:error, :account_closed}
  end

  def execute(
        %Account{},
        %C.WithdrawFromAccount{}
      ) do
    {:error, :not_found}
  end

  # process manager

  def execute(
        %Account{
          uuid: account_uuid,
          closed?: true
        },
        %C.TransferBetweenAccounts{
          account_uuid: account_uuid
        }
      ) do
    {:error, :account_closed}
  end

  def execute(
        %Account{uuid: account_uuid, closed?: false},
        %C.TransferBetweenAccounts{
          account_uuid: account_uuid,
          destination_account_uuid: destination_account_uuid
        }
      )
      when account_uuid == destination_account_uuid do
    {:error, :transfer_to_same_account}
  end

  def execute(
        %Account{
          uuid: account_uuid,
          closed?: false,
          current_balance: current_balance
        },
        %C.TransferBetweenAccounts{
          account_uuid: account_uuid,
          transfer_amount: transfer_amount
        }
      )
      when current_balance < transfer_amount do
    {:error, :insufficient_funds}
  end

  def execute(
        %Account{uuid: account_uuid, closed?: false},
        %C.TransferBetweenAccounts{
          account_uuid: account_uuid,
          transfer_uuid: transfer_uuid,
          transfer_amount: transfer_amount,
          destination_account_uuid: destination_account_uuid
        }
      ) do
    %E.MoneyTransferRequested{
      transfer_uuid: transfer_uuid,
      source_account_uuid: account_uuid,
      amount: transfer_amount,
      destination_account_uuid: destination_account_uuid
    }
  end

  def execute(
        %Account{},
        %C.TransferBetweenAccounts{}
      ) do
    {:error, :not_found}
  end

  # state mutators

  def apply(
        %Account{} = account,
        %E.AccountOpened{
          account_uuid: account_uuid,
          initial_balance: initial_balance
        }
      ) do
    %Account{
      account
      | uuid: account_uuid,
        current_balance: initial_balance
    }
  end

  def apply(
        %Account{uuid: account_uuid} = account,
        %E.AccountClosed{
          account_uuid: account_uuid
        }
      ) do
    %Account{
      account
      | closed?: true
    }
  end

  def apply(
        %Account{
          uuid: account_uuid,
          current_balance: _current_balance
        } = account,
        %E.DepositedIntoAccount{
          account_uuid: account_uuid,
          new_current_balance: new_current_balance
        }
      ) do
    %Account{
      account
      | current_balance: new_current_balance
    }
  end

  def apply(
        %Account{
          uuid: account_uuid,
          current_balance: _current_balance
        } = account,
        %E.WithdrawnFromAccount{
          account_uuid: account_uuid,
          new_current_balance: new_current_balance
        }
      ) do
    %Account{
      account
      | current_balance: new_current_balance
    }
  end

  def apply(
        %Account{} = account,
        %E.MoneyTransferRequested{}
      ) do
    account
  end
end
