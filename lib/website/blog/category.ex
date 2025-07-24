defmodule Website.Blog.Category do
  @moduledoc """
  Blog category schema for organizing blog posts.

  Categories provide a way to group and filter blog posts by topic or theme.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :description, :string
    field :slug, :string

    has_many :posts, Website.Blog.Post

    timestamps(type: :utc_datetime)
  end

  @doc """
  Creates a changeset for blog category creation and updates.

  Validates slug format and uniqueness for URL generation.
  """
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :slug, :description])
    |> validate_required([:name, :slug, :description])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/, message: "must contain only lowercase letters, numbers, and hyphens")
    |> unique_constraint(:slug)
    |> unique_constraint(:name)
  end
end
