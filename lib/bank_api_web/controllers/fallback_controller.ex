defmodule BankAPIWeb.FallbackController do
  use BankAPIWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: BankAPIWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :account_already_closed}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: BankAPIWeb.ErrorJSON)
    |> render(:"422")
  end

  def call(conn, {:error, :account_closed}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: BankAPIWeb.ErrorJSON)
    |> assign(:message, "Account closed")
    |> render(:"422")
  end

  def call(conn, {:error, :bad_command}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: BankAPIWeb.ErrorJSON)
    |> assign(:message, "Bad command")
    |> render(:"422")
  end

  def call(conn, {:error, :insufficient_funds}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: BankAPIWeb.ErrorJSON)
    |> assign(:message, "Insufficient funds to process order")
    |> render(:"422")
  end

  def call(conn, {:error, :command_validation_failure, _command, _errors}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: BankAPIWeb.ErrorJSON)
    |> assign(:message, "Command validation error")
    |> render(:"422")
  end

  def call(conn, {:error, :transfer_to_same_account}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: BankAPIWeb.ErrorJSON)
    |> assign(:message, "Source and destination accounts are the same")
    |> render("422.json")
  end
end
