defmodule Website.Repo.Migrations.AddDatabaseConstraintsAndIndexes do
  use Ecto.Migration

  def up do
    # Add unique constraints for slugs (these may already exist but we'll add them explicitly)
    # Posts slugs
    create_if_not_exists unique_index(:posts, [:slug])

    # Categories slugs  
    create_if_not_exists unique_index(:categories, [:slug])

    # Project statuses slugs
    create_if_not_exists unique_index(:project_statuses, [:slug])
    create_if_not_exists unique_index(:project_statuses, [:name])

    # Technologies slugs
    create_if_not_exists unique_index(:technologies, [:slug])
    create_if_not_exists unique_index(:technologies, [:name])

    # Photo categories slugs
    create_if_not_exists unique_index(:photo_categories, [:slug])

    # Add check constraints for priority_score range (1-10)
    create constraint(:photos, :priority_score_range,
             check: "priority_score >= 1 AND priority_score <= 10"
           )

    # Add check constraints for visual_weight enum values
    create constraint(:photos, :visual_weight_enum,
             check: "visual_weight IN ('light', 'medium', 'heavy')"
           )

    # Add check constraints for focal point ranges (0.0-1.0)
    create constraint(:photos, :focal_point_x_range,
             check: "focal_point_x >= 0.0 AND focal_point_x <= 1.0"
           )

    create constraint(:photos, :focal_point_y_range,
             check: "focal_point_y >= 0.0 AND focal_point_y <= 1.0"
           )

    # Add check constraint for hex color format in photo_categories
    create constraint(:photo_categories, :color_format, check: "color ~ '^#[0-9a-fA-F]{6}$'")

    # Add composite indexes for common query patterns
    # Posts by status and insertion date (for published posts queries)
    create_if_not_exists index(:posts, [:status, :inserted_at])

    # Posts by category and status (for category filtering)
    create_if_not_exists index(:posts, [:category_id, :status])

    # Photos by category and priority (for gallery display)
    create_if_not_exists index(:photos, [:photo_category_id, :priority_score])

    # Projects by status and featured flag
    create_if_not_exists index(:projects, [:project_status_id, :featured])

    # Add proper foreign key constraints with cascade behavior
    # Note: Some of these may already exist, but we'll ensure proper cascade behavior

    # Drop existing foreign key constraints if they exist (to recreate with proper cascade)
    drop_if_exists constraint(:posts, "posts_category_id_fkey")
    drop_if_exists constraint(:photos, "photos_photo_category_id_fkey")
    drop_if_exists constraint(:projects, "projects_project_status_id_fkey")

    # Recreate with proper cascade behavior
    alter table(:posts) do
      modify :category_id, references(:categories, on_delete: :restrict, on_update: :update_all)
    end

    alter table(:photos) do
      modify :photo_category_id,
             references(:photo_categories, on_delete: :restrict, on_update: :update_all)
    end

    alter table(:projects) do
      modify :project_status_id,
             references(:project_statuses, on_delete: :restrict, on_update: :update_all)
    end
  end

  def down do
    # Remove composite indexes
    drop_if_exists index(:posts, [:status, :inserted_at])
    drop_if_exists index(:posts, [:category_id, :status])
    drop_if_exists index(:photos, [:photo_category_id, :priority_score])
    drop_if_exists index(:projects, [:project_status_id, :featured])

    # Remove check constraints
    drop constraint(:photos, :priority_score_range)
    drop constraint(:photos, :visual_weight_enum)
    drop constraint(:photos, :focal_point_x_range)
    drop constraint(:photos, :focal_point_y_range)
    drop constraint(:photo_categories, :color_format)

    # Remove unique indexes (only the ones we explicitly added)
    drop_if_exists index(:posts, [:slug])
    drop_if_exists index(:categories, [:slug])
    drop_if_exists index(:project_statuses, [:slug])
    drop_if_exists index(:project_statuses, [:name])
    drop_if_exists index(:technologies, [:slug])
    drop_if_exists index(:technologies, [:name])
    drop_if_exists index(:photo_categories, [:slug])

    # Note: We're not reverting the foreign key constraint changes in down
    # as that could cause data integrity issues. These should be handled
    # manually if needed.
  end
end
