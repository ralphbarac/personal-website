defmodule Website.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias Website.Repo

  alias Website.Projects.{Project, ProjectStatus, Technology}

  @doc """
  Returns the list of projects with preloaded associations.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Project
    |> preload([:project_status, :technologies])
    |> order_by([p], [desc: p.featured, desc: p.inserted_at])
    |> Repo.all()
  end

  @doc """
  Returns the list of featured projects.

  ## Examples

      iex> list_featured_projects()
      [%Project{}, ...]

  """
  def list_featured_projects do
    Project
    |> where([p], p.featured == true)
    |> preload([:project_status, :technologies])
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id) do
    Project
    |> preload([:project_status, :technologies])
    |> Repo.get!(id)
  end

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  @doc """
  Associates technologies with a project.

  ## Examples

      iex> associate_technologies(project, [tech1, tech2])
      {:ok, %Project{}}

  """
  def associate_technologies(%Project{} = project, technologies) do
    project
    |> Repo.preload(:technologies)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:technologies, technologies)
    |> Repo.update()
  end

  # Project Status functions

  @doc """
  Returns the list of project_statuses.

  ## Examples

      iex> list_project_statuses()
      [%ProjectStatus{}, ...]

  """
  def list_project_statuses do
    Repo.all(ProjectStatus)
  end

  @doc """
  Gets a single project_status.

  Raises `Ecto.NoResultsError` if the Project status does not exist.

  ## Examples

      iex> get_project_status!(123)
      %ProjectStatus{}

      iex> get_project_status!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project_status!(id), do: Repo.get!(ProjectStatus, id)

  @doc """
  Gets a project status by slug.

  ## Examples

      iex> get_project_status_by_slug("live")
      %ProjectStatus{}

      iex> get_project_status_by_slug("nonexistent")
      nil

  """
  def get_project_status_by_slug(slug) do
    Repo.get_by(ProjectStatus, slug: slug)
  end

  @doc """
  Creates a project_status.

  ## Examples

      iex> create_project_status(%{field: value})
      {:ok, %ProjectStatus{}}

      iex> create_project_status(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project_status(attrs \\ %{}) do
    %ProjectStatus{}
    |> ProjectStatus.changeset(attrs)
    |> Repo.insert()
  end

  # Technology functions

  @doc """
  Returns the list of technologies.

  ## Examples

      iex> list_technologies()
      [%Technology{}, ...]

  """
  def list_technologies do
    Technology
    |> order_by([t], t.name)
    |> Repo.all()
  end

  @doc """
  Gets a single technology.

  Raises `Ecto.NoResultsError` if the Technology does not exist.

  ## Examples

      iex> get_technology!(123)
      %Technology{}

      iex> get_technology!(456)
      ** (Ecto.NoResultsError)

  """
  def get_technology!(id), do: Repo.get!(Technology, id)

  @doc """
  Gets a technology by slug.

  ## Examples

      iex> get_technology_by_slug("elixir")
      %Technology{}

      iex> get_technology_by_slug("nonexistent")
      nil

  """
  def get_technology_by_slug(slug) do
    Repo.get_by(Technology, slug: slug)
  end

  @doc """
  Gets technologies by their slugs.

  ## Examples

      iex> get_technologies_by_slugs(["elixir", "phoenix"])
      [%Technology{}, %Technology{}]

  """
  def get_technologies_by_slugs(slugs) when is_list(slugs) do
    Technology
    |> where([t], t.slug in ^slugs)
    |> Repo.all()
  end

  @doc """
  Creates a technology.

  ## Examples

      iex> create_technology(%{field: value})
      {:ok, %Technology{}}

      iex> create_technology(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_technology(attrs \\ %{}) do
    %Technology{}
    |> Technology.changeset(attrs)
    |> Repo.insert()
  end
end