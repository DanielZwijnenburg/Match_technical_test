defmodule VendingMachineWeb.PageController do
  use VendingMachineWeb, :controller

  alias VendingMachine.Products

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    products = Products.list_products()
    render(conn, :home, layout: false, products: products)
  end
end
