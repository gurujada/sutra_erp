defmodule SutraErpWeb.UserRegistrationLiveTest do
  use SutraErpWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import SutraErp.AccountsFixtures

  describe "Registration page" do
    test "renders registration page with all fields", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/register")

      assert html =~ "Register"
      assert html =~ "Log in"

      assert html =~ "Username"
      assert html =~ "First Name"
      assert html =~ "Middle Name"
      assert html =~ "Last Name"
      assert html =~ "Time Zone"
      assert html =~ "Gender"
      assert html =~ "Mobile Number"
      assert html =~ "Confirm Password"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/register")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end

    #
    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(
          user: %{
            "email" => "invalid email with spaces",
            "password" => "short",
            "password_confirmation" => "different",
            "username" => "invalid username!@#",
            # testing required field
            "first_name" => "ad",
            "mobile_number" => "invalid-phone",
            "gender" => "invalid_gender"
          }
        )

      # Email validation
      assert result =~ "must have the @ sign and no spaces"
      # Password validation
      assert result =~ "should be at least 12 character"
      # Password confirmation validation
      # assert result =~ "does not match password"
      # Username format validation
      assert result =~ "only letters, numbers, and underscores allowed"
      # Required fields validation
      # assert result =~ "can't be blank"
      # Mobile number format validation
      assert result =~ "invalid mobile number format"
      # Gender enum validation
      assert result =~ "is invalid"
    end

    test "gender selection works correctly", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(%{
          "user" => %{"gender" => "male"}
        })

      assert result =~ "male"
    end

    test "timezone selection works correctly", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(%{
          "user" => %{"timezone" => "UTC"}
        })

      assert result =~ "UTC"
    end
  end

  describe "register user" do
    test "creates account and logs the user in", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      email = unique_user_email()
      form = form(lv, "#registration_form", user: valid_user_attributes(email: email))
      render_submit(form)
      conn = follow_trigger_action(form, conn)

      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ email
      assert response =~ "Settings"
      assert response =~ "Log out"
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      user = user_fixture(%{email: "test@email.com"})

      result =
        lv
        |> form("#registration_form",
          user: %{"email" => user.email, "password" => "valid_password"}
        )
        |> render_submit()

      assert result =~ "has already been taken"
    end
  end

  describe "registration navigation" do
    test "redirects to login page when the Log in button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s|main a:fl-contains("Log in")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/users/log_in")

      assert login_html =~ "Log in"
    end
  end

  # describe "Avatar upload" do
  #   test "shows upload input with correct restrictions", %{conn: conn} do
  #     {:ok, view, _html} = live(conn, ~p"/users/register")

  #     assert render(view) =~ "photos (max 10 MB each)"
  #     assert render(view) =~ "phx-drop-target"
  #   end

  #   test "validates file type", %{conn: conn} do
  #     {:ok, view, _html} = live(conn, ~p"/users/register")

  #     file = %{
  #       last_modified: 1_594_171_879_000,
  #       name: "test.txt",
  #       content: "test content",
  #       type: "text/plain"
  #     }

  #     render_upload(view, :avatar, [file])

  #     assert render(view) =~ "not a valid format"
  #   end

  #   # test "validates file size", %{conn: conn} do
  #   #   {:ok, view, _html} = live(conn, ~p"/users/register")

  #   #   file = %{
  #   #     last_modified: 1_594_171_879_000,
  #   #     name: "large.jpg",
  #   #     content: String.duplicate("0", 11_000_000),
  #   #     type: "image/jpeg"
  #   #   }

  #   #   render_upload(view, :avatar, [file])

  #   #   assert render(view) =~ "too large"
  #   # end

  #   # test "uploads valid image", %{conn: conn} do
  #   #   {:ok, view, _html} = live(conn, ~p"/users/register")

  #   #   file = %{
  #   #     last_modified: 1_594_171_879_000,
  #   #     name: "avatar.jpg",
  #   #     content: "test image content",
  #   #     type: "image/jpeg"
  #   #   }

  #   #   # Simulate upload
  #   #   render_upload(view, :avatar, [file])

  #   #   # Check preview is shown
  #   #   assert render(view) =~ "live-img-preview"
  #   # end

  #   # test "allows canceling upload", %{conn: conn} do
  #   #   {:ok, view, _html} = live(conn, ~p"/users/register")

  #   #   file = %{
  #   #     last_modified: 1_594_171_879_000,
  #   #     name: "avatar.jpg",
  #   #     content: "test image content",
  #   #     type: "image/jpeg"
  #   #   }

  #   #   # Upload file
  #   #   render_upload(view, :avatar, [file])
  #   #   assert render(view) =~ "live-img-preview"

  #   #   # Cancel upload
  #   #   assert view
  #   #          |> element("a", "X")
  #   #          |> render_click()

  #   #   refute render(view) =~ "live-img-preview"
  #   # end

  #   # test "successfully registers user with avatar", %{conn: conn} do
  #   #   {:ok, view, _html} = live(conn, ~p"/users/register")

  #   #   file = %{
  #   #     last_modified: 1_594_171_879_000,
  #   #     name: "avatar.jpg",
  #   #     content: "test image content",
  #   #     type: "image/jpeg"
  #   #   }

  #   #   # Upload avatar
  #   #   render_upload(view, :avatar, [file])

  #   #   # Submit form with valid user data
  #   #   attrs = valid_user_attributes()

  #   #   view
  #   #   |> form("#registration_form", user: attrs)
  #   #   |> render_submit()

  #   #   # Follow redirect
  #   #   conn = follow_trigger_action(view, conn)

  #   #   # Verify registration and avatar
  #   #   assert redirected_to(conn) == ~p"/"
  #   #   user = Accounts.get_user_by_email(attrs.email)
  #   #   assert user.avatar =~ "/uploads/"
  #   # end

  #   # test "handles multiple upload attempts", %{conn: conn} do
  #   #   {:ok, view, _html} = live(conn, ~p"/users/register")

  #   #   files = [
  #   #     %{
  #   #       last_modified: 1_594_171_879_000,
  #   #       name: "avatar1.jpg",
  #   #       content: "test content 1",
  #   #       type: "image/jpeg"
  #   #     },
  #   #     %{
  #   #       last_modified: 1_594_171_879_000,
  #   #       name: "avatar2.jpg",
  #   #       content: "test content 2",
  #   #       type: "image/jpeg"
  #   #     }
  #   #   ]

  #   #   # Try to upload multiple files
  #   #   Enum.each(files, &render_upload(view, :avatar, [&1]))

  #   #   # Should only show the latest upload
  #   #   assert render(view) =~ "avatar2.jpg"
  #   #   refute render(view) =~ "avatar1.jpg"
  #   # end
  # end

  # Helper function to create test directory if it doesn't exist
  # setup do
  #   uploads_dir = Path.join(["priv", "static", "uploads"])
  #   File.mkdir_p!(uploads_dir)

  #   on_exit(fn ->
  #     # Cleanup uploaded files after test
  #     File.ls!(uploads_dir)
  #     |> Enum.each(fn file ->
  #       File.rm!(Path.join(uploads_dir, file))
  #     end)
  #   end)

  #   :ok
  # end
end
