defmodule VendingMachineWeb.Api.V1.UserJSON do
  alias VendingMachine.Accounts.User

  def show(%{user: user, token: token}) do
    json =
      data(user)
      |> Map.merge(%{token: token})
    %{data: json}
  end

  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      role: user.role,
      deposit: user.deposit
    }
  end
end
