defmodule Website.Projects.Technology do
  @moduledoc """
  Technology schema for tagging projects with tech stacks.

  Represents programming languages, frameworks, tools, and technologies used in projects.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "technologies" do
    field :name, :string
    field :slug, :string

    many_to_many :projects, Website.Projects.Project, join_through: "project_technologies"

    timestamps(type: :utc_datetime)
  end

  @doc """
  Creates a changeset for technology creation and updates.

  Validates slug format and ensures uniqueness for both name and slug.
  """
  def changeset(technology, attrs) do
    technology
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "must contain only lowercase letters, numbers, and hyphens"
    )
    |> unique_constraint(:slug)
    |> unique_constraint(:name)
  end
end
