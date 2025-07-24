defmodule Website.Repo.Migrations.RemoveOldPhotosAndStringCategory do
  use Ecto.Migration

  def change do
    # Remove old photo records that don't have photo_category_id
    execute "DELETE FROM photos WHERE photo_category_id IS NULL", ""
    
    # Remove the old category string column
    alter table(:photos) do
      remove :category
    end
  end
end
