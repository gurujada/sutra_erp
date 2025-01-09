defmodule SutraErp.Repo.Migrations.AddFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :status, :boolean, default: true
      add :username, :string
      add :first_name, :string
      add :middle_name, :string
      add :last_name, :string
      add :timezone, :string
      add :avatar, :string
      add :gender, :string
      add :mobile_number, :string
    end

    # create unique_index(:users, [:username])
    create index(:users, [:username])
  end
end
