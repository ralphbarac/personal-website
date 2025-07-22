defmodule Website.Projects.ProjectStatus do
  use Ecto.Schema
  import Ecto.Changeset

  schema "project_statuses" do
    field :name, :string
    field :description, :string
    field :slug, :string

    has_many :projects, Website.Projects.Project

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project_status, attrs) do
    project_status
    |> cast(attrs, [:name, :slug, :description])
    |> validate_required([:name, :slug, :description])
    |> unique_constraint(:slug)
    |> unique_constraint(:name)
  end
end
