defmodule VendingMachineWeb.Api.V1.BuyProductControllerTest do
  use VendingMachineWeb.ConnCase

  import VendingMachine.AccountsFixtures
  import VendingMachine.ProductsFixtures

  describe "buy_product" do
    setup %{conn: conn} do
      user = user_fixture(role: "buyer", deposit: 555)
      seller = user_fixture(role: "seller", deposit: 500)
      product = product_fixture(user_id: seller.id, cost: 20, amount_available: 5)

      conn
      |> put_req_header("accept", "application/json")

      {:ok, conn: conn, user: user, product: product}
    end

    test "returns unauthorized if not authenticated", %{conn: conn, product: product} do
      buy_params = %{
        "product_id" => product.id,
        "amount_of_products" => product.amount_available + 1
      }

      conn =
        conn
        |> post(~p"/api/v1/buy", buy_product: buy_params)

      assert json_response(conn, 401) ==
        %{"errors" => [%{"detail" => "Unauthorized", "status" => 401}]}
    end

    test "returns unauthorized if authenticated user is not a seller", %{conn: conn, product: product} do
      user = user_fixture(role: "seller")

      buy_params = %{
        "product_id" => product.id,
        "amount_of_products" => product.amount_available + 1
      }

      conn =
        conn
        |> log_in_api_user(user)
        |> post(~p"/api/v1/buy", buy_product: buy_params)

      assert json_response(conn, 401) == %{"errors" => [%{"detail" => "Only users with role: buyer are allowed to access this endpoint", "status" => 401}]}
    end

    test "successful product purchase", %{conn: conn, user: user, product: product} do
      %{id: user_id, email: email} = user
      %{id: product_id, amount_available: amount_available, user_id: seller_id} = product

      available_products = amount_available - 1

      buy_params = %{
        "product_id" => product_id,
        "amount_of_products" => 1
      }

      conn =
        conn
        |> log_in_api_user(user)
        |> post(~p"/api/v1/buy", buy_product: buy_params)

      %{
        "data" => %{
          "change" => %{"10" => 1, "100" => 5, "20" => 1, "5" => 1},
          "product" => %{
            "amount_available" => ^available_products,
            "cost" => 20,
            "id" => ^product_id,
            "name" => "product name",
            "user_id" => ^seller_id
          },
          "total_spent" => 20,
          "user" => %{
            "deposit" => 0,
            "email" => ^email,
            "id" => ^user_id,
            "role" => "buyer"
          }
        }
      } = json_response(conn, 201)
    end

    test "returns error when product is not available", %{conn: conn, user: user, product: product} do
      buy_params = %{
        "product_id" => product.id,
        "amount_of_products" => product.amount_available + 1
      }

      conn =
        conn
        |> log_in_api_user(user)
        |> post(~p"/api/v1/buy", buy_product: buy_params)

      assert json_response(conn, 422) == %{"errors" => [%{"detail" => "exceeding_available_products", "status" => 422}]}

    end

    test "returns error when user has insufficient deposit", %{conn: conn, product: product} do
      user = user_fixture(role: "buyer", deposit: 5)
      buy_params = %{
        "product_id" => product.id,
        "amount_of_products" => 1
      }

      conn =
        conn
        |> log_in_api_user(user)
        |> post(~p"/api/v1/buy", buy_product: buy_params)

      assert json_response(conn, 422) == %{"errors" => [%{"detail" => "insufficient_deposit", "status" => 422}]}

    end
  end
end
