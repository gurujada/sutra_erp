defmodule SutraErp.Repo do
  use Ecto.Repo,
    otp_app: :sutra_erp,
    adapter: Ecto.Adapters.Postgres
end
