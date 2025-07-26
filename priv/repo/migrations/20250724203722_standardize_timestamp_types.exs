defmodule Website.Repo.Migrations.StandardizeTimestampTypes do
  use Ecto.Migration

  def up do
    # Convert naive_datetime timestamps to utc_datetime for consistency
    # This affects photos and photo_categories tables

    alter table(:photos) do
      modify :inserted_at, :utc_datetime, null: false
      modify :updated_at, :utc_datetime, null: false
    end

    alter table(:photo_categories) do
      modify :inserted_at, :utc_datetime, null: false
      modify :updated_at, :utc_datetime, null: false
    end
  end

  def down do
    # Revert back to naive_datetime
    alter table(:photos) do
      modify :inserted_at, :naive_datetime, null: false
      modify :updated_at, :naive_datetime, null: false
    end

    alter table(:photo_categories) do
      modify :inserted_at, :naive_datetime, null: false
      modify :updated_at, :naive_datetime, null: false
    end
  end
end
