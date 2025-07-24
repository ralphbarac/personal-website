defmodule Website.Repo.Migrations.AddMetadataToPhotos do
  use Ecto.Migration

  def change do
    alter table(:photos) do
      add :width, :integer
      add :height, :integer
      add :aspect_ratio, :float
      add :priority_score, :integer, default: 5
      add :visual_weight, :string, default: "medium"
      add :focal_point_x, :float
      add :focal_point_y, :float
    end
  end
end
