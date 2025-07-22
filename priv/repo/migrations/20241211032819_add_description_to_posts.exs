defmodule Website.Repo.Migrations.AddDescriptionToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :description, :text, null: false
    end
  end
end
