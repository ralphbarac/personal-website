defmodule Website.Repo.Migrations.UpdateBlogImagePaths do
  use Ecto.Migration

  def up do
    # Update existing blog image paths to use the new uploads directory structure
    execute(
      "UPDATE posts SET image_path = '/images/blog/uploads/escaping_tutorials.jpg' WHERE image_path = '/images/blog/escaping_tutorials.jpg'"
    )
  end

  def down do
    # Revert back to old path structure
    execute(
      "UPDATE posts SET image_path = '/images/blog/escaping_tutorials.jpg' WHERE image_path = '/images/blog/uploads/escaping_tutorials.jpg'"
    )
  end
end
