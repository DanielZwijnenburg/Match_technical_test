defmodule VendingMachineWeb.Api.V1.DepositControllerTest do
  use VendingMachineWeb.ConnCase

  import VendingMachine.AccountsFixtures
  import VendingMachine.DepositsFixtures

  @invalid_attrs %{}

  setup %{conn: conn} do
    user = user_fixture(role: "buyer")

    conn
    |> put_req_header("accept", "application/json")

    {:ok, conn: conn, user: user}
  end

  describe "index" do
    test "returns unauthorized if not authenticated", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/deposits")

      assert json_response(conn, 401) == %{"errors" => [%{"detail" => "Unauthorized", "status" => 401}]}
    end

    test "returns unauthorized if authenticated user is not a buyer", %{conn: conn} do
      user = user_fixture(role: "seller")

      conn =
        conn
        |> log_in_api_user(user)
        |> get(~p"/api/v1/deposits")

      assert json_response(conn, 401) == %{"errors" => [%{"detail" => "Only users with role: buyer are allowed to access this endpoint", "status" => 401}]}
    end

    test "returns current users deposits when authenticated", %{conn: conn, user: user} do
      %{amount: amount, coin_type: coin_type} = deposit_fixture(user_id: user.id)
      conn =
        conn
        |> log_in_api_user(user)
        |> get(~p"/api/v1/deposits")

      [%{"amount" => ^amount, "coin_type" => ^coin_type}] = json_response(conn, 200)["data"]
    end
  end

  describe "create (deposit) deposit" do
    test "returns unauthorized if not authenticated", %{conn: conn} do
      conn =
        conn
        |> post(~p"/api/v1/deposits", deposit: @invalid_attrs)

      assert json_response(conn, 401) ==
        %{"errors" => [%{"detail" => "Unauthorized", "status" => 401}]}
    end

    test "returns deposit when data is valid", %{conn: conn, user: user} do
      %{amount: amount} = params = valid_deposit_attributes(user_id: user.id, amount: 50)
      conn =
        conn
        |> log_in_api_user(user)
        |> post(~p"/api/v1/deposits", deposit: params)

      assert %{"amount" => ^amount} = json_response(conn, 201)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        conn
        |> log_in_api_user(user)
        |> post(~p"/api/v1/deposits", deposit: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
