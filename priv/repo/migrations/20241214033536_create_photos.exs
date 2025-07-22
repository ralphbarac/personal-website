defmodule Website.Repo.Migrations.CreatePhotos do
  use Ecto.Migration

  def change do
    create table(:photos) do
      add :description, :text, null: false
      add :category, :string, null: false
      add :image_path, :string, null: false

      timestamps()
    end
  end
end
