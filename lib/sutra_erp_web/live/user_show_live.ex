defmodule SutraErpWeb.UserShowLive do
  use SutraErpWeb, :live_view

  alias SutraErp.Accounts

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        <.link href={~p"/users"}>Users</.link>
        <:subtitle>Show user</:subtitle>
      </.header>

      {inspect(@user)}
     
    </div>
    """
  end

  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:user, Accounts.get_user!(id))}
  end
end
