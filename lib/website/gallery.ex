defmodule Website.Gallery do
  @moduledoc """
  The Gallery context handles photo-related queries and business logic.
  """

  import Ecto.Query
  alias Website.Repo
  alias Website.{Photo, PhotoCategory}

  @doc """
  Fetches all photos from the database with preloaded categories.
  """
  def fetch_photos() do
    Photo
    |> preload(:photo_category)
    |> Repo.all()
  end

  @doc """
  Fetches photos filtered by the given category. If "All" is passed, it returns all photos.
  """
  def fetch_photos_by_category("All") do
    Photo
    |> preload(:photo_category)
    |> Repo.all()
  end

  def fetch_photos_by_category(category_name) do
    Photo
    |> join(:inner, [p], c in assoc(p, :photo_category))
    |> where([p, c], c.name == ^category_name)
    |> preload(:photo_category)
    |> Repo.all()
  end

  @doc """
  Gets all photo categories from the database.
  """
  def get_categories do
    PhotoCategory
    |> select([c], c.name)
    |> order_by([c], c.name)
    |> Repo.all()
  end

  @doc """
  Gets all categories including "All" option.
  """
  def get_categories_with_all do
    ["All" | get_categories()]
  end

  @doc """
  Gets all photo categories as structs.
  """
  def list_photo_categories do
    PhotoCategory
    |> order_by([c], c.name)
    |> Repo.all()
  end

  @doc """
  Gets a single photo category by name.
  """
  def get_photo_category_by_name(name) do
    Repo.get_by(PhotoCategory, name: name)
  end

  @doc """
  Gets a single photo category by slug.
  """
  def get_photo_category_by_slug(slug) do
    Repo.get_by(PhotoCategory, slug: slug)
  end

  @doc """
  Creates a photo category.
  """
  def create_photo_category(attrs \\ %{}) do
    %PhotoCategory{}
    |> PhotoCategory.create_changeset(attrs)
    |> Repo.insert()
  end
end
