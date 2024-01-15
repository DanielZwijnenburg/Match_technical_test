defmodule VendingMachineWeb.Api.V1.UserJSON do
  alias VendingMachine.Accounts.User

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      email: user.email
    }
  end
end
