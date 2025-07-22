defmodule Website.Repo.Migrations.AddReadTimeToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :read_time, :integer, null: false, default: 0
    end
  end
end
