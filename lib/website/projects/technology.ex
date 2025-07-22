defmodule Website.Projects.Technology do
  use Ecto.Schema
  import Ecto.Changeset

  schema "technologies" do
    field :name, :string
    field :slug, :string

    many_to_many :projects, Website.Projects.Project, join_through: "project_technologies"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(technology, attrs) do
    technology
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> unique_constraint(:slug)
    |> unique_constraint(:name)
  end
end
