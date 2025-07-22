defmodule Website.Photo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "photos" do
    field :description, :string
    field :category, :string
    field :image_path, :string

    timestamps()
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:description, :category, :image_path])
    |> validate_required([:description, :category, :image_path])
  end
end
