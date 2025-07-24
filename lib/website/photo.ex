defmodule Website.Photo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "photos" do
    field :description, :string
    field :image_path, :string
    field :width, :integer
    field :height, :integer
    field :aspect_ratio, :float
    field :priority_score, :integer, default: 5
    field :visual_weight, :string, default: "medium"
    field :focal_point_x, :float
    field :focal_point_y, :float

    belongs_to :photo_category, Website.PhotoCategory

    timestamps()
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:description, :image_path, :width, :height, :aspect_ratio, 
                    :priority_score, :visual_weight, :focal_point_x, :focal_point_y, :photo_category_id])
    |> validate_required([:description, :photo_category_id])
    |> validate_inclusion(:visual_weight, ["light", "medium", "heavy"])
    |> validate_number(:priority_score, greater_than_or_equal_to: 1, less_than_or_equal_to: 10)
    |> validate_number(:focal_point_x, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0)
    |> validate_number(:focal_point_y, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0)
    |> foreign_key_constraint(:photo_category_id)
    |> maybe_calculate_aspect_ratio()
  end

  @doc false
  def create_changeset(photo, attrs) do
    photo
    |> cast(attrs, [:description, :image_path, :width, :height, :aspect_ratio, 
                    :priority_score, :visual_weight, :focal_point_x, :focal_point_y, :photo_category_id])
    |> validate_required([:description, :image_path, :photo_category_id])
    |> validate_inclusion(:visual_weight, ["light", "medium", "heavy"])
    |> validate_number(:priority_score, greater_than_or_equal_to: 1, less_than_or_equal_to: 10)
    |> validate_number(:focal_point_x, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0)
    |> validate_number(:focal_point_y, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0)
    |> foreign_key_constraint(:photo_category_id)
    |> maybe_calculate_aspect_ratio()
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
