defmodule Website.Repo.Migrations.RemoveCategoryNotNullConstraint do
  use Ecto.Migration

  def change do
    alter table(:photos) do
      modify :category, :string, null: true
    end
  end
end
