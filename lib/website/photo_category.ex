defmodule Website.PhotoCategory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "photo_categories" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :color, :string, default: "#10b981"

    has_many :photos, Website.Photo

    timestamps()
  end

  @doc false
  def changeset(photo_category, attrs) do
    photo_category
    |> cast(attrs, [:name, :slug, :description, :color])
    |> validate_required([:name, :slug])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/, message: "must contain only lowercase letters, numbers, and hyphens")
    |> validate_format(:color, ~r/^#[0-9a-fA-F]{6}$/, message: "must be a valid hex color")
    |> unique_constraint(:slug)
  end

  @doc false
  def create_changeset(photo_category, attrs) do
    photo_category
    |> cast(attrs, [:name, :slug, :description, :color])
    |> validate_required([:name])
    |> maybe_generate_slug()
    |> validate_required([:slug])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/, message: "must contain only lowercase letters, numbers, and hyphens")
    |> validate_format(:color, ~r/^#[0-9a-fA-F]{6}$/, message: "must be a valid hex color")
    |> unique_constraint(:slug)
  end

  # Automatically generate slug from name if not provided
  defp maybe_generate_slug(changeset) do
    case get_change(changeset, :slug) do
      nil ->
        case get_change(changeset, :name) do
          nil -> changeset
          name -> put_change(changeset, :slug, slugify(name))
        end
      _slug -> changeset
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