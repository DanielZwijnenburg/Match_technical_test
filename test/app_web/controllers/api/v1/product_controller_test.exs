defmodule VendingMachineWeb.Api.V1.ProductControllerTest do
  use VendingMachineWeb.ConnCase

  import VendingMachine.AccountsFixtures
  import VendingMachine.ProductsFixtures

  @invalid_attrs %{}

  setup %{conn: conn} do
    user = user_fixture(role: "seller")

    conn
    |> put_req_header("accept", "application/json")

    {:ok, conn: conn, user: user}
  end

  describe "index" do
    test "returns data if not authenticated", %{conn: conn, user: user} do
      %{cost: cost, amount_available: amount_available} = product_fixture(user_id: user.id)
      conn = get(conn, ~p"/api/v1/products")

      [%{"cost" => ^cost, "amount_available" => ^amount_available}] = json_response(conn, 200)["data"]
    end

    test "returns data if authenticated", %{conn: conn, user: user} do
      %{cost: cost, amount_available: amount_available} = product_fixture(user_id: user.id)
      conn =
        conn
        |> log_in_api_user(user)
        |> get(~p"/api/v1/products")

      [%{"cost" => ^cost, "amount_available" => ^amount_available}] = json_response(conn, 200)["data"]
    end
  end

  describe "create product" do
    test "returns unauthorized if not authenticated", %{conn: conn} do
      conn =
        conn
        |> post(~p"/api/v1/products", product: @invalid_attrs)

      assert json_response(conn, 401) ==
        %{"errors" => [%{"detail" => "Unauthorized", "status" => 401}]}
    end

    test "returns unauthorized if authenticated user is not a seller", %{conn: conn} do
      user = user_fixture(role: "buyer")

      conn =
        conn
        |> log_in_api_user(user)
        |> post(~p"/api/v1/products", product: @invalid_attrs)

      assert json_response(conn, 401) == %{"errors" => [%{"detail" => "Only users with role: seller are allowed to access this endpoint", "status" => 401}]}
    end

    test "returns product when data is valid", %{conn: conn, user: user} do
      %{cost: cost} = params = valid_product_attributes(user_id: user.id, cost: 50)
      conn =
        conn
        |> log_in_api_user(user)
        |> post(~p"/api/v1/products", product: params)

      assert %{"cost" => ^cost} = json_response(conn, 201)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        conn
        |> log_in_api_user(user)
        |> post(~p"/api/v1/products", product: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show" do
    test "returns not found if product not found", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/products/-1")

      assert json_response(conn, 404) ==
        %{"errors" => [%{"detail" => "not found", "status" => 404}]}
    end

    test "returns data if not authenticated", %{conn: conn, user: user} do
      %{id: id, cost: cost, amount_available: amount_available} = product =
        product_fixture(user_id: user.id)
      conn = get(conn, ~p"/api/v1/products/#{product}")

      %{"cost" => ^cost, "amount_available" => ^amount_available, "id" => ^id} =
        json_response(conn, 200)["data"]
    end

    test "returns data if authenticated", %{conn: conn, user: user} do
      %{id: id, cost: cost, amount_available: amount_available} = product =
        product_fixture(user_id: user.id)
      conn =
        conn
        |> log_in_api_user(user)
        |> get(~p"/api/v1/products/#{product}")

      %{"cost" => ^cost, "amount_available" => ^amount_available, "id" => ^id} =
        json_response(conn, 200)["data"]
    end
  end

  describe "update product" do
    test "renders product when data is valid", %{conn: conn, user: user} do
      updated_amount = 100
      %{id: id} = product = product_fixture(user_id: user.id)

      conn = put(conn, ~p"api/v1/products/#{product}", product: %{amount: updated_amount})
      assert %{"id" => ^id} = json_response(conn, 200)["data"]
      assert %{"amount" => ^amount} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      conn = put(conn, ~p"<%= schema.api_route_prefix %>/#{product}", product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
