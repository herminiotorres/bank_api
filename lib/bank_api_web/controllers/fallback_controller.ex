defmodule BankAPIWeb.FallbackController do
  use BankAPIWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: BankAPIWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:validation_error, _changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: BankAPIWeb.ErrorJSON)
    |> render(:"442")
  end
end
