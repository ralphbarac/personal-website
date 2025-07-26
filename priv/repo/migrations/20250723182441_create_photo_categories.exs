defmodule Website.Repo.Migrations.CreatePhotoCategories do
  use Ecto.Migration

  def change do
    create table(:photo_categories) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :text
      # emerald-500
      add :color, :string, default: "#10b981"

      timestamps()
    end

    create unique_index(:photo_categories, [:slug])
    create index(:photo_categories, [:name])
  end
end
