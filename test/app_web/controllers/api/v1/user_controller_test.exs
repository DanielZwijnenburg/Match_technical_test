defmodule VendingMachineWeb.Api.V1.UserControllerTest do
  use VendingMachineWeb.ConnCase

  import VendingMachine.AccountsFixtures

  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create (register) user" do
    test "renders user when data is valid", %{conn: conn} do
      email = unique_user_email()
      conn = post(conn, ~p"/api/v1/users", user: valid_user_attributes(email: email))
      assert %{"email" => ^email} = json_response(conn, 201)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/users", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when email is already registered", %{conn: conn} do
      email = unique_user_email()
      conn = post(conn, ~p"/api/v1/users", user: valid_user_attributes(email: email))
      assert %{"email" => ^email} = json_response(conn, 201)["data"]
      conn = post(conn, ~p"/api/v1/users", user: valid_user_attributes(email: email))
      assert json_response(conn, 422)["errors"] == %{"email" => ["has already been taken"]}
    end
  end
end
