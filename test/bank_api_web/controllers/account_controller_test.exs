defmodule BankAPIWeb.AccountControllerTest do
  use BankAPIWeb.ConnCase, async: true

  @create_attrs %{
    initial_balance: 42_00
  }
  @invalid_attrs %{
    initial_balance: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create account" do
    test "renders account when data is valid", %{conn: conn} do
      conn =
        post(
          conn,
          ~p"/api/accounts",
          account: @create_attrs
        )

      assert %{
               "uuid" => _uuid,
               "current_balance" => 4200
             } = json_response(conn, 201)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(
          conn,
          ~p"/api/accounts",
          account: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
