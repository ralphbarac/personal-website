defmodule Website.Projects.Project do
  @moduledoc """
  Project schema for portfolio management.

  Represents individual projects with status, technologies, and external links.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :description, :string
    field :title, :string
    field :github_url, :string
    field :live_url, :string
    field :featured, :boolean, default: false

    belongs_to :project_status, Website.Projects.ProjectStatus
    many_to_many :technologies, Website.Projects.Technology, join_through: "project_technologies", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc """
  Creates a changeset for project creation and updates.

  Validates URLs if provided and ensures required fields are present.
  """
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:title, :description, :github_url, :live_url, :featured, :project_status_id])
    |> validate_required([:title, :description, :project_status_id])
    |> validate_url(:github_url)
    |> validate_url(:live_url)
    |> foreign_key_constraint(:project_status_id)
  end

  # Validates URL format if the field is not nil or empty
  defp validate_url(changeset, field) do
    case get_change(changeset, field) do
      nil -> changeset
      "" -> changeset
      url -> 
        case URI.parse(url) do
          %URI{scheme: scheme, host: host} when scheme in ["http", "https"] and not is_nil(host) ->
            changeset
          _ ->
            add_error(changeset, field, "must be a valid URL")
        end
    end
  end
end
