defmodule Website.Photo do
  @moduledoc """
  Photo schema for the website gallery system.

  Represents individual photos with metadata for layout and display purposes.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @valid_visual_weights ~w(light medium heavy)a

  schema "photos" do
    field :description, :string
    field :image_path, :string
    field :width, :integer
    field :height, :integer
    field :aspect_ratio, :float
    field :priority_score, :integer, default: 5
    field :visual_weight, Ecto.Enum, values: [:light, :medium, :heavy], default: :medium
    field :focal_point_x, :float
    field :focal_point_y, :float

    belongs_to :photo_category, Website.PhotoCategory

    timestamps(type: :utc_datetime)
  end

  @doc """
  Creates a changeset for photo creation.

  Requires image_path for new photos but allows updates without it.
  Automatically calculates aspect ratio from width and height.
  """
  def changeset(photo, attrs, opts \\ []) do
    require_image_path = Keyword.get(opts, :require_image_path, photo.id == nil)

    required_fields =
      case require_image_path do
        true -> [:description, :image_path, :photo_category_id]
        false -> [:description, :photo_category_id]
      end

    photo
    |> cast(attrs, [
      :description,
      :image_path,
      :width,
      :height,
      :aspect_ratio,
      :priority_score,
      :visual_weight,
      :focal_point_x,
      :focal_point_y,
      :photo_category_id
    ])
    |> validate_required(required_fields)
    |> validate_inclusion(:visual_weight, @valid_visual_weights)
    |> validate_number(:priority_score, greater_than_or_equal_to: 1, less_than_or_equal_to: 10)
    |> validate_number(:focal_point_x, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0)
    |> validate_number(:focal_point_y, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0)
    |> foreign_key_constraint(:photo_category_id)
    |> maybe_calculate_aspect_ratio()
  end

  @doc """
  Creates a changeset specifically for photo creation.
  Alias for changeset/2 with require_image_path: true.
  """
  def create_changeset(photo, attrs) do
    changeset(photo, attrs, require_image_path: true)
  end

  # Automatically calculate aspect ratio if width and height are provided
  defp maybe_calculate_aspect_ratio(changeset) do
    width = get_change(changeset, :width)
    height = get_change(changeset, :height)

    if width && height && height != 0 do
      put_change(changeset, :aspect_ratio, width / height)
    else
      changeset
    end
  end
end
