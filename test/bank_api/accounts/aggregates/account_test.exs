defmodule BankApi.Accounts.Aggregates.AccountTest do
  use BankAPI.Test.InMemoryEventStoreCase

  alias BankAPI.Accounts.Aggregates.Account, as: Aggregate
  alias BankAPI.Accounts.Events.AccountOpened
  alias BankAPI.Accounts.Commands.OpenAccount

  test "ensure aggregate gets correct state on creation" do
    uuid = Ecto.UUID.generate()

    account =
      %Aggregate{}
      |> evolve(%AccountOpened{
        initial_balance: 1_000,
        account_uuid: uuid
      })

    assert account.uuid == uuid
    assert account.current_balance == 1_000
  end

  test "errors out on invalid opening balance" do
    invalid_command = %OpenAccount{
      initial_balance: -1_000,
      account_uuid: Ecto.UUID.generate()
    }

    assert {:error, :initial_balance_must_be_above_zero} =
             Aggregate.execute(%Aggregate{}, invalid_command)
  end

  test "errors out on already opened account" do
    command = %OpenAccount{
      initial_balance: 1_000,
      account_uuid: Ecto.UUID.generate()
    }

    assert {:error, :account_already_opened} =
             Aggregate.execute(%Aggregate{uuid: Ecto.UUID.generate()}, command)
  end
end
