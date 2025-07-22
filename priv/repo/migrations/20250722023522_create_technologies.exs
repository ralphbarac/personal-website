defmodule Website.Repo.Migrations.CreateTechnologies do
  use Ecto.Migration

  def change do
    create table(:technologies) do
      add :name, :string
      add :slug, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:technologies, [:slug])
    create unique_index(:technologies, [:name])
  end
end
