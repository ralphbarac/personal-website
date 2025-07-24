defmodule Website.Repo.Migrations.AddPhotoCategoryToPhotos do
  use Ecto.Migration

  def change do
    alter table(:photos) do
      add :photo_category_id, references(:photo_categories, on_delete: :restrict)
    end

    create index(:photos, [:photo_category_id])
    
    # Keep the old category string column temporarily for data migration
  end
end
