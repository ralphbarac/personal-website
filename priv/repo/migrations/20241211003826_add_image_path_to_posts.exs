defmodule Website.Repo.Migrations.AddImagePathToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :image_path, :string, null: false
    end
  end
end
