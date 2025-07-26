defmodule WebsiteWeb.AdminCategoriesLive do
  use WebsiteWeb, :live_view

  alias Website.Blog
  alias Website.Blog.Category

  def mount(_params, _session, socket) do
    categories = Blog.list_categories()

    socket =
      socket
      |> assign(:current_path, "/admin/categories")
      |> assign(:categories, categories)
      |> assign(:changeset, Blog.change_category(%Category{}))
      |> assign(:editing_category, nil)

    {:ok, socket}
  end

  def handle_event("validate", %{"category" => category_params}, socket) do
    changeset =
      case socket.assigns.editing_category do
        nil -> Blog.change_category(%Category{}, category_params)
        category -> Blog.change_category(category, category_params)
      end
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"category" => category_params}, socket) do
    case Blog.create_category(category_params) do
      {:ok, _category} ->
        categories = Blog.list_categories()

        socket =
          socket
          |> assign(:categories, categories)
          |> assign(:changeset, Blog.change_category(%Category{}))
          |> put_flash(:info, "Category created successfully!")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    category = Blog.get_category!(id)
    changeset = Blog.change_category(category)

    socket =
      socket
      |> assign(:editing_category, category)
      |> assign(:changeset, changeset)

    {:noreply, socket}
  end

  def handle_event("update", %{"category" => category_params}, socket) do
    case Blog.update_category(socket.assigns.editing_category, category_params) do
      {:ok, _category} ->
        categories = Blog.list_categories()

        socket =
          socket
          |> assign(:categories, categories)
          |> assign(:editing_category, nil)
          |> assign(:changeset, Blog.change_category(%Category{}))
          |> put_flash(:info, "Category updated successfully!")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("cancel_edit", _params, socket) do
    socket =
      socket
      |> assign(:editing_category, nil)
      |> assign(:changeset, Blog.change_category(%Category{}))

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    category = Blog.get_category!(id)

    case Blog.delete_category(category) do
      {:ok, _category} ->
        categories = Blog.list_categories()

        socket =
          socket
          |> assign(:categories, categories)
          |> put_flash(:info, "Category deleted successfully!")

        {:noreply, socket}

      {:error, :has_posts} ->
        socket =
          put_flash(
            socket,
            :error,
            "Cannot delete category that has posts. Please move or delete the posts first."
          )

        {:noreply, socket}

      {:error, _changeset} ->
        socket = put_flash(socket, :error, "Failed to delete category.")
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
              <h1 class="text-3xl font-bold text-slate-900">Blog Categories</h1>
              <p class="mt-2 text-slate-600">Manage blog post categories and organization</p>
            </div>
            <div class="flex items-center gap-4">
              <.link
                navigate="/admin/blog"
                class="inline-flex items-center px-4 py-2 bg-emerald-600 text-white font-semibold rounded-lg shadow hover:bg-emerald-700 transition-colors"
              >
                <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C20.832 18.477 19.246 18 17.5 18c-1.746 0-3.332.477-4.5 1.253"
                  />
                </svg>
                Blog Posts
              </.link>
              <.link
                navigate="/admin"
                class="bg-slate-600 text-white px-4 py-2 rounded-lg hover:bg-slate-700"
              >
                Back to Admin
              </.link>
            </div>
          </div>
        </div>
      </div>

      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Category Form -->
        <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6 mb-8">
          <h2 class="text-xl font-semibold text-slate-900 mb-4">
            <%= if @editing_category, do: "Edit Category", else: "Create New Category" %>
          </h2>

          <.form
            :let={f}
            for={@changeset}
            phx-submit={if @editing_category, do: "update", else: "save"}
            phx-change="validate"
          >
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div>
                <label class="block text-sm font-medium text-slate-700 mb-2">
                  Name <span class="text-red-500">*</span>
                </label>
                <.input field={f[:name]} type="text" placeholder="e.g., Technology, Travel" />
              </div>

              <div>
                <label class="block text-sm font-medium text-slate-700 mb-2">
                  Slug <span class="text-red-500">*</span>
                </label>
                <.input field={f[:slug]} type="text" placeholder="e.g., technology, travel" />
                <p class="mt-1 text-xs text-slate-500">URL-friendly version (lowercase, hyphens)</p>
              </div>

              <div>
                <label class="block text-sm font-medium text-slate-700 mb-2">
                  Description <span class="text-red-500">*</span>
                </label>
                <.input
                  field={f[:description]}
                  type="text"
                  placeholder="Brief description of the category"
                />
              </div>
            </div>

            <div class="mt-6 flex items-center gap-4">
              <button
                type="submit"
                class="bg-emerald-600 text-white px-6 py-2 rounded-lg hover:bg-emerald-700 font-medium"
              >
                <%= if @editing_category, do: "Update Category", else: "Create Category" %>
              </button>

              <%= if @editing_category do %>
                <button
                  type="button"
                  phx-click="cancel_edit"
                  class="bg-slate-600 text-white px-6 py-2 rounded-lg hover:bg-slate-700"
                >
                  Cancel
                </button>
              <% end %>
            </div>
          </.form>
        </div>
        <!-- Categories List -->
        <div class="bg-white rounded-lg shadow-sm border border-slate-200 overflow-hidden">
          <div class="px-6 py-4 border-b border-slate-200">
            <h2 class="text-xl font-semibold text-slate-900">
              Existing Categories (<%= length(@categories) %>)
            </h2>
          </div>

          <%= if Enum.empty?(@categories) do %>
            <div class="text-center py-12">
              <svg
                class="mx-auto h-12 w-12 text-slate-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"
                />
              </svg>
              <h3 class="mt-2 text-sm font-medium text-slate-900">No categories found</h3>
              <p class="mt-1 text-sm text-slate-500">
                Get started by creating your first blog category.
              </p>
            </div>
          <% else %>
            <div class="overflow-x-auto">
              <table class="min-w-full divide-y divide-slate-200">
                <thead class="bg-slate-50">
                  <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                      Name
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                      Slug
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                      Description
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                      Created
                    </th>
                    <th class="px-6 py-3 text-right text-xs font-medium text-slate-500 uppercase tracking-wider">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-slate-200">
                  <tr :for={category <- @categories} class="hover:bg-slate-50">
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="text-sm font-medium text-slate-900"><%= category.name %></div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="text-sm text-slate-500 font-mono"><%= category.slug %></div>
                    </td>
                    <td class="px-6 py-4">
                      <div class="text-sm text-slate-500 max-w-xs truncate">
                        <%= category.description %>
                      </div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="text-sm text-slate-500">
                        <%= Calendar.strftime(category.inserted_at, "%b %d, %Y") %>
                      </div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-2">
                      <button
                        phx-click="edit"
                        phx-value-id={category.id}
                        class="text-emerald-600 hover:text-emerald-900"
                      >
                        Edit
                      </button>
                      <button
                        phx-click="delete"
                        phx-value-id={category.id}
                        data-confirm="Are you sure you want to delete this category? This action cannot be undone if no posts are using it."
                        class="text-red-600 hover:text-red-900"
                      >
                        Delete
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
