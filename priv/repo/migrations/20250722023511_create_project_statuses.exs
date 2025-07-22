defmodule Website.Repo.Migrations.CreateProjectStatuses do
  use Ecto.Migration

  def change do
    create table(:project_statuses) do
      add :name, :string
      add :slug, :string
      add :description, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:project_statuses, [:slug])
    create unique_index(:project_statuses, [:name])
  end
end
