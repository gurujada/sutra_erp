defmodule SutraErp.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SutraErp.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"
  def unique_username, do: "user#{System.unique_integer()}"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: "hello_world123",
      password_confirmation: "hello_world123",
      username: unique_username(),
      first_name: "John",
      last_name: "Doe",
      timezone: "UTC",
      gender: :male,
      mobile_number: "+1234567890"
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> SutraErp.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
