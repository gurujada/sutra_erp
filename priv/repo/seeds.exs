# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SutraErp.Repo.insert!(%SutraErp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias SutraErp.Repo
alias SutraErp.Accounts.User

# Clear existing users (optional)
Repo.delete_all(User)

# Basic time zones list (simplified)
time_zones = ["UTC", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"]

IO.puts("Starting to seed users...")

# Create users in batches of 100 for better performance
1..100
|> Enum.chunk_every(100)
|> Enum.each(fn chunk ->
  chunk
  |> Enum.map(fn index ->
    %{
      email: "user#{index}@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      username: "user#{index}",
      first_name: "First#{index}",
      middle_name: "Middle#{index}",
      last_name: "Last#{index}",
      timezone: Enum.at(time_zones, rem(index, 5)),
      avatar: "/images/default_avatar.png",
      gender: Enum.at([:male, :female, :other], rem(index, 3)),
      mobile_number: "+1#{String.pad_leading("#{index}", 10, "0")}",
      status: true,
      confirmed_at: DateTime.utc_now()
    }
  end)
  |> Enum.each(fn user_params ->
    %User{}
    |> User.registration_changeset(user_params)
    |> Repo.insert!()
  end)

  IO.puts("Inserted batch of users...")
end)

users_count = Repo.aggregate(User, :count)
IO.puts("Finished seeding #{users_count} users!")
