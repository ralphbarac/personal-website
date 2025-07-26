defmodule Website.Gallery do
  @moduledoc """
  The Gallery context.

  This context handles all photo gallery functionality including photos and photo categories.
  It provides optimized queries for gallery display, photo management, and category organization
  with proper preloading strategies to avoid N+1 queries.
  """

  import Ecto.Query, warn: false
  alias Website.Repo
  alias Website.{Photo, PhotoCategory, ImageAnalyzer}

  # Photo functions

  @doc """
  Returns all photos ordered by priority score and insertion date with preloaded categories.

  ## Examples

      iex> list_photos()
      [%Photo{}, ...]

  """
  def list_photos do
    Photo
    |> order_by([p], desc: p.priority_score, desc: p.inserted_at)
    |> preload(:photo_category)
    |> Repo.all()
  end

  @doc """
  Returns all photos ordered by insertion date (newest first) with preloaded categories.
  Used for admin interfaces where chronological order is preferred.
  """
  def list_photos_by_date do
    Photo
    |> order_by([p], desc: p.inserted_at)
    |> preload(:photo_category)
    |> Repo.all()
  end

  @doc """
  Returns photos filtered by category with preloaded associations.

  Pass "All" or nil for all photos.

  ## Examples

      iex> list_photos_by_category("Portraits")
      [%Photo{}, ...]

      iex> list_photos_by_category("All")
      [%Photo{}, ...]

  """
  def list_photos_by_category(category_name) when category_name in ["All", nil] do
    list_photos()
  end

  def list_photos_by_category(category_name) do
    Photo
    |> join(:inner, [p], c in assoc(p, :photo_category))
    |> where([p, c], c.name == ^category_name)
    |> order_by([p], desc: p.priority_score, desc: p.inserted_at)
    |> preload(:photo_category)
    |> Repo.all()
  end

  @doc """
  Returns photos filtered by category ID with preloaded associations.

  ## Examples

      iex> list_photos_by_category_id(1)
      [%Photo{}, ...]

  """
  def list_photos_by_category_id(category_id) do
    Photo
    |> where([p], p.photo_category_id == ^category_id)
    |> order_by([p], desc: p.priority_score, desc: p.inserted_at)
    |> preload(:photo_category)
    |> Repo.all()
  end

  @doc """
  Gets a single photo by ID with preloaded category.

  Raises `Ecto.NoResultsError` if the Photo does not exist.

  ## Examples

      iex> get_photo!(123)
      %Photo{}

      iex> get_photo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_photo!(id) do
    Photo
    |> preload(:photo_category)
    |> Repo.get!(id)
  end

  @doc """
  Creates a photo.

  ## Examples

      iex> create_photo(%{description: "Sunset", image_path: "/path.jpg"})
      {:ok, %Photo{}}

      iex> create_photo(%{description: ""})
      {:error, %Ecto.Changeset{}}

  """
  def create_photo(attrs \\ %{}) do
    changeset = Photo.create_changeset(%Photo{}, attrs)
    
    changeset = 
      if changeset.valid? do
        add_image_analysis_to_changeset(changeset)
      else
        changeset
      end

    Repo.insert(changeset)
  end

  @doc """
  Updates a photo.

  ## Examples

      iex> update_photo(photo, %{description: "New description"})
      {:ok, %Photo{}}

      iex> update_photo(photo, %{description: ""})
      {:error, %Ecto.Changeset{}}

  """
  def update_photo(%Photo{} = photo, attrs) do
    changeset = Photo.changeset(photo, attrs)
    
    changeset = 
      if changeset.valid? do
        add_image_analysis_to_changeset(changeset)
      else
        changeset
      end

    Repo.update(changeset)
  end

  @doc """
  Deletes a photo.

  ## Examples

      iex> delete_photo(photo)
      {:ok, %Photo{}}

      iex> delete_photo(photo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_photo(%Photo{} = photo) do
    Repo.delete(photo)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking photo changes.

  ## Examples

      iex> change_photo(photo)
      %Ecto.Changeset{data: %Photo{}}

  """
  def change_photo(%Photo{} = photo, attrs \\ %{}) do
    Photo.changeset(photo, attrs)
  end

  @doc """
  Returns the count of photos.

  ## Examples

      iex> count_photos()
      42

  """
  def count_photos do
    Repo.aggregate(Photo, :count, :id)
  end

  @doc """
  Returns photos count by category for analytics.

  ## Examples

      iex> count_photos_by_category()
      [%{category: "Portraits", count: 5}, ...]

  """
  def count_photos_by_category do
    Photo
    |> join(:inner, [p], c in assoc(p, :photo_category))
    |> group_by([p, c], c.name)
    |> select([p, c], %{category: c.name, count: count(p.id)})
    |> order_by([p, c], c.name)
    |> Repo.all()
  end

  # Photo Category functions

  @doc """
  Returns all photo categories ordered by name.

  ## Examples

      iex> list_photo_categories()
      [%PhotoCategory{}, ...]

  """
  def list_photo_categories do
    PhotoCategory
    |> order_by([c], c.name)
    |> Repo.all()
  end

  @doc """
  Returns photo categories with photo counts for admin interface.

  ## Examples

      iex> list_photo_categories_with_counts()
      [%{category: %PhotoCategory{}, photo_count: 5}, ...]

  """
  def list_photo_categories_with_counts do
    PhotoCategory
    |> join(:left, [c], p in assoc(c, :photos))
    |> group_by([c], c.id)
    |> select([c, p], %{
      category: c,
      photo_count: count(p.id)
    })
    |> order_by([c], c.name)
    |> Repo.all()
  end

  @doc """
  Returns category names as strings, including "All" option.

  ## Examples

      iex> get_category_names_with_all()
      ["All", "Portraits", "Landscapes"]

  """
  def get_category_names_with_all do
    category_names =
      PhotoCategory
      |> select([c], c.name)
      |> order_by([c], c.name)
      |> Repo.all()

    ["All" | category_names]
  end

  @doc """
  Returns category names as strings only.

  ## Examples

      iex> get_category_names()
      ["Portraits", "Landscapes"]

  """
  def get_category_names do
    PhotoCategory
    |> select([c], c.name)
    |> order_by([c], c.name)
    |> Repo.all()
  end

  @doc """
  Gets a single photo category by ID.

  Raises `Ecto.NoResultsError` if the PhotoCategory does not exist.

  ## Examples

      iex> get_photo_category!(123)
      %PhotoCategory{}

      iex> get_photo_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_photo_category!(id) do
    Repo.get!(PhotoCategory, id)
  end

  @doc """
  Gets a photo category by name.

  ## Examples

      iex> get_photo_category_by_name("Portraits")
      %PhotoCategory{}

      iex> get_photo_category_by_name("Nonexistent")
      nil

  """
  def get_photo_category_by_name(name) do
    Repo.get_by(PhotoCategory, name: name)
  end

  @doc """
  Gets a photo category by slug.

  ## Examples

      iex> get_photo_category_by_slug("portraits")
      %PhotoCategory{}

      iex> get_photo_category_by_slug("nonexistent")
      nil

  """
  def get_photo_category_by_slug(slug) do
    Repo.get_by(PhotoCategory, slug: slug)
  end

  @doc """
  Creates a photo category.

  ## Examples

      iex> create_photo_category(%{name: "Portraits"})
      {:ok, %PhotoCategory{}}

      iex> create_photo_category(%{name: ""})
      {:error, %Ecto.Changeset{}}

  """
  def create_photo_category(attrs \\ %{}) do
    %PhotoCategory{}
    |> PhotoCategory.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a photo category.

  ## Examples

      iex> update_photo_category(category, %{name: "New Name"})
      {:ok, %PhotoCategory{}}

      iex> update_photo_category(category, %{name: ""})
      {:error, %Ecto.Changeset{}}

  """
  def update_photo_category(%PhotoCategory{} = category, attrs) do
    category
    |> PhotoCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a photo category if it has no associated photos.

  ## Examples

      iex> delete_photo_category(category)
      {:ok, %PhotoCategory{}}

      iex> delete_photo_category(category_with_photos)
      {:error, :has_photos}

  """
  def delete_photo_category(%PhotoCategory{} = category) do
    case has_photos?(category.id) do
      true -> {:error, :has_photos}
      false -> Repo.delete(category)
    end
  end

  # Private helper functions

  defp add_image_analysis_to_changeset(changeset) do
    image_path = Ecto.Changeset.get_field(changeset, :image_path)
    description = Ecto.Changeset.get_field(changeset, :description) || ""
    category_id = Ecto.Changeset.get_field(changeset, :photo_category_id)
    
    if image_path && image_path != "" do
      try do
        category_name = if category_id do
          try do
            category = get_photo_category!(category_id)
            category.name
          rescue
            Ecto.NoResultsError -> ""
          end
        else
          ""
        end
        
        analysis = ImageAnalyzer.analyze_image(image_path, description, category_name)
        
        visual_weight = case analysis.visual_weight do
          weight when is_atom(weight) -> weight
          weight when is_binary(weight) -> String.to_atom(weight)
          _ -> :medium
        end
        changeset
        |> put_change_if_empty(:width, analysis.width)
        |> put_change_if_empty(:height, analysis.height)
        |> put_change_if_empty(:aspect_ratio, analysis.aspect_ratio)
        |> put_change_if_empty(:priority_score, analysis.priority_score)
        |> put_change_if_empty(:visual_weight, visual_weight)
        |> put_change_if_empty(:focal_point_x, analysis.focal_point_x)
        |> put_change_if_empty(:focal_point_y, analysis.focal_point_y)
      rescue
        error ->
          require Logger
          Logger.warning("ImageAnalyzer failed for #{image_path}: #{inspect(error)}")
          changeset
          |> put_change_if_empty(:width, 1200)
          |> put_change_if_empty(:height, 1200)
          |> put_change_if_empty(:aspect_ratio, 1.0)
          |> put_change_if_empty(:priority_score, 5)
          |> put_change_if_empty(:visual_weight, :medium)
          |> put_change_if_empty(:focal_point_x, 0.5)
          |> put_change_if_empty(:focal_point_y, 0.5)
      end
    else
      changeset
    end
  end

  defp put_change_if_empty(changeset, field, value) do
    if Ecto.Changeset.get_change(changeset, field) do
      changeset
    else
      Ecto.Changeset.put_change(changeset, field, value)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking photo category changes.

  ## Examples

      iex> change_photo_category(category)
      %Ecto.Changeset{data: %PhotoCategory{}}

  """
  def change_photo_category(%PhotoCategory{} = category, attrs \\ %{}) do
    PhotoCategory.changeset(category, attrs)
  end

  # Private functions

  defp has_photos?(category_id) do
    Photo
    |> where([p], p.photo_category_id == ^category_id)
    |> Repo.aggregate(:count, :id) > 0
  end

  # Legacy function aliases for backward compatibility
  @doc false
  def fetch_photos, do: list_photos()

  @doc false
  def fetch_photos_by_category(category), do: list_photos_by_category(category)

  @doc false
  def get_categories, do: get_category_names()

  @doc false
  def get_categories_with_all, do: get_category_names_with_all()
end
