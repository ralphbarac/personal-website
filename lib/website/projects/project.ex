defmodule Website.Projects.Project do
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

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:title, :description, :github_url, :live_url, :featured, :project_status_id])
    |> validate_required([:title, :description, :project_status_id])
    |> foreign_key_constraint(:project_status_id)
  end
end
