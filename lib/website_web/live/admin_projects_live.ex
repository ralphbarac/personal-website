defmodule WebsiteWeb.AdminProjectsLive do
  use WebsiteWeb, :live_view

  alias Website.Projects
  alias Website.Projects.{Project, Technology}

  def mount(_params, _session, socket) do
    projects = Projects.list_projects()
    project_statuses = Projects.list_project_statuses()
    technologies = Projects.list_technologies()

    socket =
      socket
      |> stream(:projects, projects)
      |> assign(:project_statuses, project_statuses)
      |> stream(:technologies, technologies)
      |> assign(:changeset, Projects.change_project(%Project{}))
      |> assign(:editing_project, nil)
      |> assign(:selected_technology_ids, [])
      |> assign(:technology_changeset, nil)

    {:ok, socket}
  end

  def handle_event("validate", %{"project" => project_params}, socket) do
    changeset = Projects.change_project(%Project{}, project_params)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    selected_tech_ids = parse_technology_ids(project_params)

    case Projects.create_project(project_params) do
      {:ok, project} ->
        # Associate technologies if any selected
        final_project =
          if length(selected_tech_ids) > 0 do
            technologies = Enum.map(selected_tech_ids, &Projects.get_technology!/1)

            case Projects.associate_technologies(project, technologies) do
              {:ok, updated_project} -> updated_project
              # Fall back to project without tech associations
              {:error, _} -> project
            end
          else
            project
          end

        # Get the fully loaded project with associations
        project_with_associations = Projects.get_project!(final_project.id)

        socket =
          socket
          |> stream_insert(:projects, project_with_associations)
          |> assign(:changeset, Projects.change_project(%Project{}))
          |> assign(:selected_technology_ids, [])
          |> put_flash(:info, "Project created successfully!")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    project = Projects.get_project!(id)
    changeset = Projects.change_project(project)
    tech_ids = Enum.map(project.technologies, & &1.id)

    socket =
      socket
      |> assign(:editing_project, project)
      |> assign(:changeset, changeset)
      |> assign(:selected_technology_ids, tech_ids)

    {:noreply, socket}
  end

  def handle_event("update", %{"project" => project_params}, socket) do
    project = socket.assigns.editing_project
    selected_tech_ids = parse_technology_ids(project_params)

    case Projects.update_project(project, project_params) do
      {:ok, updated_project} ->
        # Update technology associations
        final_project =
          if length(selected_tech_ids) > 0 do
            technologies = Enum.map(selected_tech_ids, &Projects.get_technology!/1)

            case Projects.associate_technologies(updated_project, technologies) do
              {:ok, project_with_tech} -> project_with_tech
              # Fall back to project without tech associations
              {:error, _} -> updated_project
            end
          else
            # Clear all technology associations if none selected
            case Projects.associate_technologies(updated_project, []) do
              {:ok, project_without_tech} -> project_without_tech
              {:error, _} -> updated_project
            end
          end

        # Get the fully loaded project with associations
        project_with_associations = Projects.get_project!(final_project.id)

        socket =
          socket
          |> stream_insert(:projects, project_with_associations)
          |> assign(:editing_project, nil)
          |> assign(:changeset, Projects.change_project(%Project{}))
          |> assign(:selected_technology_ids, [])
          |> put_flash(:info, "Project updated successfully!")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("cancel_edit", _params, socket) do
    socket =
      socket
      |> assign(:editing_project, nil)
      |> assign(:changeset, Projects.change_project(%Project{}))
      |> assign(:selected_technology_ids, [])

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    project = Projects.get_project!(id)

    case Projects.delete_project(project) do
      {:ok, _} ->
        socket =
          socket
          |> stream_delete(:projects, project)
          |> put_flash(:info, "Project deleted successfully!")

        {:noreply, socket}

      {:error, _changeset} ->
        socket = put_flash(socket, :error, "Failed to delete project")
        {:noreply, socket}
    end
  end

  def handle_event("toggle_featured", %{"id" => id}, socket) do
    project = Projects.get_project!(id)

    case Projects.update_project(project, %{featured: !project.featured}) do
      {:ok, updated_project} ->
        # Get fully loaded project with associations
        project_with_associations = Projects.get_project!(updated_project.id)

        socket =
          socket
          |> stream_insert(:projects, project_with_associations)
          |> put_flash(:info, "Project featured status updated!")

        {:noreply, socket}

      {:error, _changeset} ->
        socket = put_flash(socket, :error, "Failed to update project")
        {:noreply, socket}
    end
  end

  def handle_event("toggle_technology", %{"tech_id" => tech_id}, socket) do
    case parse_integer(tech_id) do
      nil ->
        {:noreply, socket}

      tech_id ->
        current_ids = socket.assigns.selected_technology_ids

        new_ids =
          if tech_id in current_ids do
            List.delete(current_ids, tech_id)
          else
            [tech_id | current_ids]
          end

        {:noreply, assign(socket, :selected_technology_ids, new_ids)}
    end
  end

  # Technology Management Events

  def handle_event("new_technology", _params, socket) do
    changeset = Technology.changeset(%Technology{}, %{})

    socket =
      socket
      |> assign(:technology_changeset, changeset)

    {:noreply, socket}
  end

  def handle_event("validate_technology", %{"technology" => technology_params}, socket) do
    technology_params = auto_generate_slug(technology_params)
    changeset = Technology.changeset(%Technology{}, technology_params)
    {:noreply, assign(socket, :technology_changeset, changeset)}
  end

  def handle_event("create_technology", %{"technology" => technology_params}, socket) do
    technology_params = auto_generate_slug(technology_params)

    case Projects.create_technology(technology_params) do
      {:ok, technology} ->
        socket =
          socket
          |> stream_insert(:technologies, technology)
          |> assign(:technology_changeset, nil)
          |> put_flash(:info, "Technology created successfully!")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :technology_changeset, changeset)}
    end
  end

  def handle_event("cancel_technology", _params, socket) do
    socket =
      socket
      |> assign(:technology_changeset, nil)

    {:noreply, socket}
  end

  def handle_event("delete_technology", %{"id" => id}, socket) do
    technology = Projects.get_technology!(id)

    case Projects.delete_technology(technology) do
      {:ok, _} ->
        # Refresh all projects to update associations after technology deletion
        projects = Projects.list_projects()

        # Update each project individually to avoid reset
        socket =
          Enum.reduce(projects, socket, fn project, acc_socket ->
            stream_insert(acc_socket, :projects, project)
          end)
          |> stream_delete(:technologies, technology)
          |> put_flash(:info, "Technology deleted successfully!")

        {:noreply, socket}

      {:error, _changeset} ->
        socket =
          socket
          |> put_flash(:error, "Cannot delete technology - it's being used by projects!")

        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-50">
      <div class="bg-white shadow-sm border-b border-slate-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="py-6 flex items-center justify-between">
            <div>
              <h1 class="text-3xl font-bold text-slate-900">Project Management</h1>
              <p class="mt-2 text-slate-600">Create and manage portfolio projects</p>
            </div>
            <.link
              navigate="/admin"
              class="bg-slate-600 text-white px-4 py-2 rounded-lg hover:bg-slate-700"
            >
              Back to Admin
            </.link>
          </div>
        </div>
      </div>

      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <.render_technology_section
          technologies={@streams.technologies}
          technology_changeset={@technology_changeset}
        />

        <.render_project_form
          changeset={@changeset}
          editing_project={@editing_project}
          project_statuses={@project_statuses}
          technologies={@streams.technologies}
          selected_technology_ids={@selected_technology_ids}
        />

        <.render_projects_list projects={@streams.projects} />
      </div>
    </div>
    """
  end

  # Helper functions for data processing and validation

  defp parse_technology_ids(project_params) do
    technology_ids = Map.get(project_params, "technology_ids", "")
    
    # Handle comma-separated string format from hidden input
    case technology_ids do
      # If it's a string (comma-separated), split and parse
      ids_string when is_binary(ids_string) ->
        if ids_string == "" do
          []
        else
          ids_string
          |> String.split(",")
          |> Enum.filter(&(&1 != ""))
          |> Enum.map(&parse_integer/1)
          |> Enum.reject(&is_nil/1)
        end
      
      # If it's already a list, process it (backward compatibility)
      ids when is_list(ids) ->
        ids
        |> Enum.filter(&(&1 != ""))
        |> Enum.map(&parse_integer/1)
        |> Enum.reject(&is_nil/1)
      
      # Fallback for any other format
      _ -> []
    end
  end

  defp parse_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> nil
    end
  end

  defp parse_integer(value) when is_integer(value), do: value
  defp parse_integer(_), do: nil

  defp auto_generate_slug(technology_params) do
    if technology_params["slug"] == "" or is_nil(technology_params["slug"]) do
      slug =
        technology_params["name"]
        |> String.downcase()
        |> String.replace(~r/[^a-z0-9\s-]/, "")
        |> String.replace(~r/\s+/, "-")
        |> String.trim("-")

      Map.put(technology_params, "slug", slug)
    else
      technology_params
    end
  end

  # Private component functions for render breakdown

  attr :technologies, :any, required: true, doc: "Stream of technologies from LiveView"
  attr :technology_changeset, :any, default: nil

  defp render_technology_section(assigns) do
    ~H"""
    <!-- Technology Management -->
    <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6 mb-8">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-xl font-semibold text-slate-900">Technology Management</h2>
        <button
          phx-click="new_technology"
          class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700"
        >
          Add New Technology
        </button>
      </div>

      <div :if={@technology_changeset} class="border border-slate-300 rounded-lg p-4 mb-4 bg-slate-50">
        <h3 class="text-lg font-medium text-slate-900 mb-3">Create New Technology</h3>

        <.form
          :let={f}
          for={@technology_changeset}
          phx-submit="create_technology"
          phx-change="validate_technology"
        >
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 mb-1">Name *</label>
              <.input field={f[:name]} type="text" placeholder="e.g., React, Python, PostgreSQL" />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 mb-1">
                Slug (auto-generated)
              </label>
              <.input field={f[:slug]} type="text" placeholder="Auto-filled from name" />
            </div>
          </div>

          <div class="mt-4 flex gap-2">
            <button
              type="submit"
              class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700"
            >
              Create Technology
            </button>
            <button
              type="button"
              phx-click="cancel_technology"
              class="bg-slate-600 text-white px-4 py-2 rounded-lg hover:bg-slate-700"
            >
              Cancel
            </button>
          </div>
        </.form>
      </div>

      <div
        id="technologies"
        phx-update="stream"
        class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-3"
      >
        <div
          :for={{id, tech} <- @technologies}
          id={id}
          class="flex items-center justify-between bg-slate-50 border border-slate-200 rounded-lg p-3"
        >
          <div class="flex-1 min-w-0">
            <span class="text-sm font-medium text-slate-900 truncate block"><%= tech.name %></span>
            <span class="text-xs text-slate-500 truncate block"><%= tech.slug %></span>
          </div>
          <button
            phx-click="delete_technology"
            phx-value-id={tech.id}
            data-confirm="Are you sure? This will remove the technology from all projects."
            class="ml-2 text-red-500 hover:text-red-700 flex-shrink-0"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1-1H9a1 1 0 00-1 1v3M4 7h16"
              />
            </svg>
          </button>
        </div>
      </div>

      <p :if={@technologies == %{}} class="text-center py-8 text-slate-500">
        No technologies available. Add your first technology above!
      </p>
    </div>
    """
  end

  attr :changeset, :any, required: true
  attr :editing_project, :any, default: nil
  attr :project_statuses, :list, required: true
  attr :technologies, :any, required: true, doc: "Stream of technologies from LiveView"
  attr :selected_technology_ids, :list, required: true

  defp render_project_form(assigns) do
    ~H"""
    <!-- Create/Edit Form -->
    <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6 mb-8">
      <h2 class="text-xl font-semibold text-slate-900 mb-4">
        <%= if @editing_project, do: "Edit Project", else: "Create New Project" %>
      </h2>

      <.form
        :let={f}
        for={@changeset}
        phx-submit={if @editing_project, do: "update", else: "save"}
        phx-change="validate"
      >
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 mb-1">Title *</label>
              <.input field={f[:title]} type="text" placeholder="e.g., Personal Website" />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-1">Description *</label>
              <.input
                field={f[:description]}
                type="textarea"
                rows="4"
                placeholder="Brief description of the project..."
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-1">Project Status *</label>
              <.input
                field={f[:project_status_id]}
                type="select"
                options={[{"Select status...", nil} | Enum.map(@project_statuses, &{&1.name, &1.id})]}
              />
            </div>

            <div class="flex items-center">
              <.input field={f[:featured]} type="checkbox" class="mr-2" />
              <label class="text-sm font-medium text-slate-700 pl-2">Featured Project</label>
            </div>
          </div>

          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 mb-1">GitHub URL</label>
              <.input
                field={f[:github_url]}
                type="url"
                placeholder="https://github.com/username/repo"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-1">Live URL</label>
              <.input field={f[:live_url]} type="url" placeholder="https://project-demo.com" />
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 mb-2">Technologies</label>
              <div 
                id="project-form-technologies"
                phx-update="stream"
                class="grid grid-cols-2 gap-2 max-h-48 overflow-y-auto border border-slate-200 rounded p-3"
              >
                <div :for={{id, tech} <- @technologies} id={id} class="flex items-center">
                  <input
                    type="checkbox"
                    id={"tech_#{tech.id}"}
                    phx-click="toggle_technology"
                    phx-value-tech_id={tech.id}
                    checked={tech.id in @selected_technology_ids}
                    class="mr-2 rounded border-slate-300"
                  />
                  <label for={"tech_#{tech.id}"} class="text-sm text-slate-700 cursor-pointer">
                    <%= tech.name %>
                  </label>
                </div>
              </div>
            </div>
          </div>
        </div>
        <!-- Hidden field to pass selected technology IDs -->
        <input 
          type="hidden" 
          name="project[technology_ids]" 
          value={Enum.join(@selected_technology_ids, ",")} 
        />

        <div class="mt-6 flex justify-end gap-2">
          <button
            :if={@editing_project}
            type="button"
            phx-click="cancel_edit"
            class="bg-slate-600 text-white px-6 py-2 rounded-lg hover:bg-slate-700"
          >
            Cancel
          </button>
          <button type="submit" class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700">
            <%= if @editing_project, do: "Update Project", else: "Create Project" %>
          </button>
        </div>
      </.form>
    </div>
    """
  end

  attr :projects, :any, required: true, doc: "Stream of projects from LiveView"

  defp render_projects_list(assigns) do
    ~H"""
    <!-- Projects List -->
    <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
      <h2 class="text-xl font-semibold text-slate-900 mb-6">
        Existing Projects
      </h2>

      <div :if={@projects == %{}} class="text-center py-12 text-slate-500">
        No projects created yet. Create your first project above!
      </div>

      <div id="projects" phx-update="stream" class="space-y-4">
        <div :for={{id, project} <- @projects} id={id} class="border border-slate-200 rounded-lg p-6">
          <div class="flex items-start justify-between">
            <div class="flex-1">
              <div class="flex items-center gap-3 mb-2">
                <h3 class="text-lg font-semibold text-slate-900"><%= project.title %></h3>
                <!-- Featured Badge -->
                <span
                  :if={project.featured}
                  class="bg-yellow-100 text-yellow-800 text-xs font-medium px-2 py-1 rounded-full"
                >
                  Featured
                </span>
                <!-- Status Badge -->
                <span class={[
                  "text-xs font-medium px-2 py-1 rounded-full",
                  case project.project_status.name do
                    "Live" -> "bg-green-100 text-green-800"
                    "In Development" -> "bg-orange-100 text-orange-800"
                    "Completed" -> "bg-blue-100 text-blue-800"
                    _ -> "bg-slate-100 text-slate-800"
                  end
                ]}>
                  <%= project.project_status.name %>
                </span>
              </div>

              <p class="text-slate-600 mb-3"><%= project.description %></p>
              <!-- Technologies -->
              <div class="flex flex-wrap gap-2 mb-3">
                <span
                  :for={tech <- project.technologies}
                  class="bg-slate-100 text-slate-700 text-xs font-medium px-2 py-1 rounded"
                >
                  <%= tech.name %>
                </span>
              </div>
              <!-- Links -->
              <div class="flex gap-4 text-sm">
                <a
                  :if={project.github_url}
                  href={project.github_url}
                  target="_blank"
                  class="text-blue-600 hover:text-blue-800"
                >
                  GitHub →
                </a>
                <a
                  :if={project.live_url}
                  href={project.live_url}
                  target="_blank"
                  class="text-green-600 hover:text-green-800"
                >
                  Live Demo →
                </a>
              </div>
            </div>

            <div class="flex gap-2 ml-4">
              <button
                phx-click="toggle_featured"
                phx-value-id={project.id}
                class={[
                  "text-sm px-3 py-1 rounded",
                  if(project.featured,
                    do: "bg-yellow-100 text-yellow-700 hover:bg-yellow-200",
                    else: "bg-slate-100 text-slate-700 hover:bg-slate-200"
                  )
                ]}
              >
                <%= if project.featured, do: "Unfeature", else: "Feature" %>
              </button>
              <button
                phx-click="edit"
                phx-value-id={project.id}
                class="text-sm bg-slate-100 text-slate-700 px-3 py-1 rounded hover:bg-slate-200"
              >
                Edit
              </button>
              <button
                phx-click="delete"
                phx-value-id={project.id}
                data-confirm="Are you sure you want to delete this project?"
                class="text-sm bg-red-100 text-red-700 px-3 py-1 rounded hover:bg-red-200"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
