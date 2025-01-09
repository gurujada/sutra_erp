defmodule SutraErpWeb.UserIndexLive do
  use SutraErpWeb, :live_view

  alias SutraErp.Accounts

  def mount(_params, _session, socket) do
    socket =
      socket
      # |> stream(:users, Accounts.list_users())
      |> assign(form: to_form(%{}), filters: %{})

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    options = %{
      "name" => params["name"] || "",
      "username" => params["username"] || "",
      "phone" => params["phone"] || ""
    }

    {:noreply,
     socket
     |> assign(filters: options)
     |> stream(:users, Accounts.list_users(options), reset: true)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-change="search">
      
        <div class="relative">
          <input
            type="text"
            id="name"
            name="name"
            class="py-3 px-4 block w-full border-gray-200 rounded-lg text-sm focus:border-blue-500 focus:ring-blue-500 disabled:opacity-50 disabled:pointer-events-none ark:bg-neutral-900 ark:border-neutral-700 ark:text-neutral-400 ark:placeholder-neutral-500 ark:focus:ring-neutral-600"
            placeholder="Search by Name"
            aria-describedby="email-error"
            value={@filters["name"]}
            autocomplete="off"
          />

          <input
            type="text"
            id="username"
            name="username"
            class="py-3 px-4 block w-full border-gray-200 rounded-lg text-sm focus:border-blue-500 focus:ring-blue-500 disabled:opacity-50 disabled:pointer-events-none ark:bg-neutral-900 ark:border-neutral-700 ark:text-neutral-400 ark:placeholder-neutral-500 ark:focus:ring-neutral-600"
            placeholder="Search by Username"
            aria-describedby="email-error"
            value={@filters["username"]}
          />

          <input
            type="tel"
            id="phone"
            name="phone"
            class="py-3 px-4 block w-full border-gray-200 rounded-lg text-sm focus:border-blue-500 focus:ring-blue-500 disabled:opacity-50 disabled:pointer-events-none ark:bg-neutral-900 ark:border-neutral-700 ark:text-neutral-400 ark:placeholder-neutral-500 ark:focus:ring-neutral-600"
            placeholder="Search by Phone"
            aria-describedby="email-error"
            value={@filters["phone"]}
          />
        </div>
        <p class="hidden text-xs text-red-600 mt-2" id="email-error">
          Please include a valid email address so we can get back to you
        </p>
      </.form>
      <div
        id="users"
        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 p-6"
        phx-update="stream"
      >
        <.user_card :for={{id, user} <- @streams.users} id={id} user={user} />
      </div>
    </div>
    """
  end

  def handle_event("search", params, socket) do
    params =
      params |> Map.take(~w(phone name username)) |> Map.reject(fn {_, v} -> v == "" end) |> dbg()

    # |> Map.merge(socket.assigns.filters)
    socket = socket |> push_patch(to: ~p"/users?#{params}")
    {:noreply, socket}
  end

  def user_card(assigns) do
    ~H"""
    <.link navigate={~p"/users/#{@user.id}"} class="block">
      <div id={@id} class="bg-white rounded-lg shadow p-6 max-w-sm">
        <div class="flex items-center space-x-4">
          <div class="flex-shrink-0">
            <img
              :if={@user.avatar}
              src={@user.avatar}
              class="h-16 w-16 rounded-full object-cover"
              alt={"Avatar of #{@user.first_name}"}
            />
            <div
              :if={!@user.avatar}
              class="h-16 w-16 rounded-full bg-gray-200 flex items-center justify-center"
            >
              <span class="text-xl text-gray-500">
                {String.first(@user.first_name)}{String.first(@user.last_name)}
              </span>
            </div>
          </div>

          <div class="flex-1 min-w-0">
            <div class="flex items-center justify-between">
              <p class="text-lg font-semibold text-gray-900 truncate">
                {@user.first_name} {@user.last_name}
              </p>
              <span class={"px-2 inline-flex text-xs leading-5 font-semibold rounded-full #{if @user.status, do: "bg-green-100 text-green-800", else: "bg-red-100 text-red-800"}"}>
                {if @user.status, do: "Active", else: "Inactive"}
              </span>
            </div>

            <div class="mt-1 text-sm text-gray-500">
              <p class="truncate">@{@user.username}</p>
              <p class="truncate">{@user.email}</p>
            </div>

            <div class="mt-2 flex items-center text-sm text-gray-500 space-x-4">
              <div>
                <.icon name="hero-phone" class="h-4 w-4 inline mr-1" />
                {@user.mobile_number}
              </div>
              <div>
                <.icon name="hero-globe-alt" class="h-4 w-4 inline mr-1" />
                {@user.timezone}
              </div>
            </div>

            <div class="mt-2 flex items-center space-x-4 text-sm">
              <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                {String.capitalize(to_string(@user.gender))}
              </span>
              <%= if @user.confirmed_at do %>
                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                  Verified
                </span>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </.link>
    """
  end
end
