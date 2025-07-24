defmodule Website.Repo.Migrations.AddStatusEnumTypes do
  use Ecto.Migration

  def up do
    # Create PostgreSQL enum types for better type safety and performance
    
    # Post status enum
    execute "CREATE TYPE post_status AS ENUM ('draft', 'published')"
    
    # Visual weight enum for photos  
    execute "CREATE TYPE visual_weight AS ENUM ('light', 'medium', 'heavy')"
    
    # Alter existing tables to use the new enum types with explicit casting
    # First, drop the default to avoid casting issues
    execute "ALTER TABLE posts ALTER COLUMN status DROP DEFAULT"
    execute "ALTER TABLE posts ALTER COLUMN status TYPE post_status USING status::post_status"
    execute "ALTER TABLE posts ALTER COLUMN status SET DEFAULT 'draft'::post_status"
    execute "ALTER TABLE posts ALTER COLUMN status SET NOT NULL"
    
    execute "ALTER TABLE photos ALTER COLUMN visual_weight DROP DEFAULT"
    execute "ALTER TABLE photos ALTER COLUMN visual_weight TYPE visual_weight USING visual_weight::visual_weight"
    execute "ALTER TABLE photos ALTER COLUMN visual_weight SET DEFAULT 'medium'::visual_weight"
    execute "ALTER TABLE photos ALTER COLUMN visual_weight SET NOT NULL"
    
    # Add database-level constraint for post status (redundant with enum but explicit)
    create constraint(:posts, :valid_status, check: "status IN ('draft', 'published')")
  end

  def down do
    # Remove the constraint first
    drop constraint(:posts, :valid_status)
    
    # Revert columns back to string type
    alter table(:posts) do
      modify :status, :string, default: "draft", null: false
    end
    
    alter table(:photos) do
      modify :visual_weight, :string, default: "medium", null: false
    end
    
    # Drop the enum types
    execute "DROP TYPE IF EXISTS post_status"
    execute "DROP TYPE IF EXISTS visual_weight"
  end
end