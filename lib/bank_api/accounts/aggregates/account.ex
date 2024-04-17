defmodule BankAPI.Accounts.Aggregates.Account do
  defstruct uuid: nil,
            current_balance: nil,
            closed?: false

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
end
