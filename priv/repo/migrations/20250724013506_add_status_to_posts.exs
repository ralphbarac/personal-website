defmodule Website.Repo.Migrations.AddStatusToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :status, :string, default: "draft", null: false
    end

    create index(:posts, [:status])
  end
end
