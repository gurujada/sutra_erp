defmodule SutraErpWeb.UserRegistrationLive do
  use SutraErpWeb, :live_view

  alias SutraErp.Accounts
  alias SutraErp.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Register for an account
        <:subtitle>
          Already registered?
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            Log in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:username]} type="text" label="Username" required />
        <.input field={@form[:first_name]} type="text" label="First Name" required />
        <.input field={@form[:middle_name]} type="text" label="Middle Name" />
        <.input field={@form[:last_name]} type="text" label="Last Name" />

        <.input field={@form[:timezone]} type="select" label="Time Zone" options={Tzdata.zone_list()} />
        <div class="my-2">
          Add upto {@uploads.avatar.max_entries} photos (max {trunc(
            @uploads.avatar.max_file_size / 1_000_000
          )} MB each)
          <div class="border-2 border-dashed border-gray-700" phx-drop-target={@uploads.avatar.ref}>
            <.live_file_input upload={@uploads.avatar} class="w-full" />
          </div>

          <.error :for={err <- upload_errors(@uploads.avatar)}>
            {Phoenix.Naming.humanize(err)}
          </.error>

          <div :for={entry <- @uploads.avatar.entries} class="mt-2">
            <.live_img_preview entry={entry} class="w-full" />
            <div>
              {entry.progress}
              <.error :for={err <- upload_errors(@uploads.avatar, entry)}>
                {Phoenix.Naming.humanize(err)}
              </.error>
              <a phx-click="cancel" phx-value-ref={entry.ref} class="text-sm font-semibold"> X </a>
              <span class="bg-red-500" style={"width: #{entry.progress}%"}></span>
            </div>
          </div>
        </div>
        <.input
          field={@form[:gender]}
          type="select"
          prompt="Select Gender"
          label="Gender"
          options={%{"Male" => :male, "Female" => :female, "Other" => :other}}
        />

        <.input field={@form[:mobile_number]} type="tel" label="Mobile Number" />
        <.input field={@form[:password]} type="password" label="Password" required />
        <.input
          field={@form[:password_confirmation]}
          type="password"
          label="Confirm Password"
          required
        />

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)
      |> allow_upload(:avatar, accept: ~w(.jpg .png .webp .jpeg), max_file_size: 10_000_000)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    avatar_url =
      consume_uploaded_entries(socket, :avatar, fn meta, entry ->
        dest = Path.join(["priv", "static", "uploads", "#{entry.uuid}-#{entry.client_name}"])

        File.cp!(meta.path, dest)
        url_path = static_path(socket, "/uploads/#{Path.basename(dest)}")
        {:ok, url_path}
      end)

    user_params = Map.put(user_params, "avatar", hd(avatar_url))

    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  def handle_event("cancel", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
