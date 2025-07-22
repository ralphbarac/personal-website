defmodule Website.Repo.Migrations.CreateProjectTechnologies do
  use Ecto.Migration

  def change do
    create table(:project_technologies, primary_key: false) do
      add :project_id, references(:projects, on_delete: :delete_all), null: false
      add :technology_id, references(:technologies, on_delete: :delete_all), null: false
    end

    create index(:project_technologies, [:project_id])
    create index(:project_technologies, [:technology_id])
    create unique_index(:project_technologies, [:project_id, :technology_id])
  end
end
