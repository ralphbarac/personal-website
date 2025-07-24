defmodule Website.Projects.ProjectStatus do
  @moduledoc """
  Project status schema for categorizing project states.

  Represents different project statuses like "In Progress", "Completed", "Planned", etc.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "project_statuses" do
    field :name, :string
    field :description, :string
    field :slug, :string

    has_many :projects, Website.Projects.Project

    timestamps(type: :utc_datetime)
  end

  @doc """
  Creates a changeset for project status creation and updates.

  Validates slug format and ensures uniqueness for both name and slug.
  """
  def changeset(project_status, attrs) do
    project_status
    |> cast(attrs, [:name, :slug, :description])
    |> validate_required([:name, :slug, :description])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/, message: "must contain only lowercase letters, numbers, and hyphens")
    |> unique_constraint(:slug)
    |> unique_constraint(:name)
  end
end
