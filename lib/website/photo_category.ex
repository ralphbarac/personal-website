defmodule Website.PhotoCategory do
  @moduledoc """
  Photo category schema for organizing gallery photos.

  Categories help organize photos in the gallery with color coding and descriptions.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "photo_categories" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :color, :string, default: "#10b981"

    has_many :photos, Website.Photo

    timestamps(type: :utc_datetime)
  end

  @doc """
  Creates a changeset for photo category.

  Automatically generates slug from name if not provided.
  Validates hex color format and slug format.
  """
  def changeset(photo_category, attrs, opts \\ []) do
    auto_generate_slug = Keyword.get(opts, :auto_generate_slug, photo_category.id == nil)

    changeset =
      photo_category
      |> cast(attrs, [:name, :slug, :description, :color])
      |> validate_required([:name])

    changeset =
      if auto_generate_slug do
        changeset |> maybe_generate_slug()
      else
        changeset
      end

    changeset
    |> validate_required([:slug])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "must contain only lowercase letters, numbers, and hyphens"
    )
    |> validate_format(:color, ~r/^#[0-9a-fA-F]{6}$/, message: "must be a valid hex color")
    |> unique_constraint(:slug)
  end

  @doc """
  Creates a changeset specifically for photo category creation.
  Alias for changeset/2 with auto_generate_slug: true.
  """
  def create_changeset(photo_category, attrs) do
    changeset(photo_category, attrs, auto_generate_slug: true)
  end

  # Automatically generate slug from name if not provided
  defp maybe_generate_slug(changeset) do
    case get_change(changeset, :slug) do
      nil ->
        case get_change(changeset, :name) do
          nil -> changeset
          name -> put_change(changeset, :slug, slugify(name))
        end

      _slug ->
        changeset
    end
  end

  # Simple slugify function
  defp slugify(string) when is_binary(string) do
    string
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/\s+/, "-")
    |> String.trim("-")
  end
end
