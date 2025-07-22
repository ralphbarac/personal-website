defmodule Website.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :title, :string
      add :description, :text
      add :github_url, :string
      add :live_url, :string
      add :featured, :boolean, default: false, null: false
      add :project_status_id, references(:project_statuses, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:projects, [:project_status_id])
  end
end
