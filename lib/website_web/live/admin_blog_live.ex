defmodule WebsiteWeb.AdminBlogLive do
  use WebsiteWeb, :live_view

  alias Website.Blog

  def mount(_params, _session, socket) do
    posts = Blog.list_posts_admin()
    categories = Blog.list_categories()

    socket =
      socket
      |> assign(:current_path, "/admin/blog")
      |> stream(:posts, posts)
      |> assign(:categories, categories)
      |> assign(:filters, %{title: "", category_id: nil, status: nil})
      |> assign(:loading, false)
      |> assign(:selected_posts, MapSet.new())
      |> assign(:bulk_action, nil)

    {:ok, socket}
  end

  def handle_event("filter", %{"filters" => filters}, socket) do
    normalized_filters = normalize_filters(filters)
    filtered_posts = Blog.list_posts_admin(normalized_filters)

    socket =
      socket
      |> stream(:posts, filtered_posts, reset: true)
      |> assign(:filters, normalized_filters)

    {:noreply, socket}
  end

  def handle_event("toggle_status", %{"id" => id}, socket) do
    post = Blog.get_post!(id) |> Website.Repo.preload(:category)

    socket = assign(socket, :loading, true)

    case Blog.toggle_post_status(post) do
      {:ok, updated_post} ->
        # Preload category for proper display
        updated_post_with_category = Website.Repo.preload(updated_post, :category)

        socket =
          socket
          |> stream_insert(:posts, updated_post_with_category)
          |> assign(:loading, false)
          |> put_flash(:info, "Post status updated successfully")

        {:noreply, socket}

      {:error, _changeset} ->
        socket =
          socket
          |> assign(:loading, false)
          |> put_flash(:error, "Failed to update post status")

        {:noreply, socket}
    end
  end

  def handle_event("delete_post", %{"id" => id}, socket) do
    post = Blog.get_post!(id)

    socket = assign(socket, :loading, true)

    case Blog.delete_post(post) do
      {:ok, _deleted_post} ->
        socket =
          socket
          |> stream_delete(:posts, post)
          |> assign(:loading, false)
          |> put_flash(:info, "Post deleted successfully")

        {:noreply, socket}

      {:error, _changeset} ->
        socket =
          socket
          |> assign(:loading, false)
          |> put_flash(:error, "Failed to delete post")

        {:noreply, socket}
    end
  end

  def handle_event("toggle_select", %{"id" => id}, socket) do
    selected_posts = socket.assigns.selected_posts
    post_id = String.to_integer(id)

    updated_selection =
      if MapSet.member?(selected_posts, post_id) do
        MapSet.delete(selected_posts, post_id)
      else
        MapSet.put(selected_posts, post_id)
      end

    socket = assign(socket, :selected_posts, updated_selection)
    {:noreply, socket}
  end

  def handle_event("select_all", _params, socket) do
    # Get all visible post IDs by re-querying with current filters
    current_posts = Blog.list_posts_admin(socket.assigns.filters)
    post_ids = Enum.map(current_posts, & &1.id)

    all_post_ids = MapSet.new(post_ids)
    socket = assign(socket, :selected_posts, all_post_ids)
    {:noreply, socket}
  end

  def handle_event("deselect_all", _params, socket) do
    socket = assign(socket, :selected_posts, MapSet.new())
    {:noreply, socket}
  end

  def handle_event("bulk_action", %{"action" => action}, socket) do
    selected_ids = MapSet.to_list(socket.assigns.selected_posts)

    if Enum.empty?(selected_ids) do
      socket = put_flash(socket, :error, "Please select posts to perform bulk action")
      {:noreply, socket}
    else
      socket = assign(socket, :loading, true)

      case action do
        "publish" ->
          perform_bulk_status_change(socket, selected_ids, :published)

        "draft" ->
          perform_bulk_status_change(socket, selected_ids, :draft)

        "delete" ->
          perform_bulk_delete(socket, selected_ids)

        _ ->
          socket =
            socket
            |> assign(:loading, false)
            |> put_flash(:error, "Invalid bulk action")

          {:noreply, socket}
      end
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-50">
      <.render_header />

      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <.render_filters filters={@filters} categories={@categories} />

        <.render_bulk_actions selected_posts={@selected_posts} loading={@loading} />
        <!-- Posts Table -->
        <div class="bg-white rounded-lg shadow-sm border border-slate-200 overflow-hidden">
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-slate-200">
              <thead class="bg-slate-50">
                <tr>
                  <th class="relative px-6 py-3 w-12">
                    <input
                      type="checkbox"
                      phx-click={
                        if MapSet.size(@selected_posts) > 0, do: "deselect_all", else: "select_all"
                      }
                      checked={MapSet.size(@selected_posts) > 0}
                      class="h-4 w-4 text-emerald-600 focus:ring-emerald-500 border-slate-300 rounded"
                    />
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                    Title
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                    Category
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                    Read Time
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                    Created
                  </th>
                  <th class="px-6 py-3 text-right text-xs font-medium text-slate-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody id="posts" phx-update="stream" class="bg-white divide-y divide-slate-200">
                <tr :for={{dom_id, post} <- @streams.posts} id={dom_id} class="hover:bg-slate-50">
                  <td class="relative px-6 py-4 w-12">
                    <input
                      type="checkbox"
                      phx-click="toggle_select"
                      phx-value-id={post.id}
                      checked={MapSet.member?(@selected_posts, post.id)}
                      class="h-4 w-4 text-emerald-600 focus:ring-emerald-500 border-slate-300 rounded"
                    />
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="text-sm font-medium text-slate-900"><%= post.title %></div>
                    <div class="text-sm text-slate-500 truncate max-w-xs">
                      <%= post.description %>
                    </div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                      <%= post.category.name %>
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span class={[
                      "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium",
                      if(post.status == :published,
                        do: "bg-green-100 text-green-800",
                        else: "bg-yellow-100 text-yellow-800"
                      )
                    ]}>
                      <%= String.capitalize(to_string(post.status)) %>
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-500">
                    <%= post.read_time %> min
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-500">
                    <%= Calendar.strftime(post.inserted_at, "%b %d, %Y") %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-2">
                    <.link
                      navigate={~p"/admin/blog/edit/#{post.id}"}
                      class="text-emerald-600 hover:text-emerald-900"
                    >
                      Edit
                    </.link>
                    <button
                      phx-click="toggle_status"
                      phx-value-id={post.id}
                      phx-disable-with="Updating..."
                      disabled={@loading}
                      class="text-blue-600 hover:text-blue-900 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      <%= if post.status == :published, do: "Unpublish", else: "Publish" %>
                    </button>
                    <button
                      phx-click="delete_post"
                      phx-value-id={post.id}
                      phx-disable-with="Deleting..."
                      data-confirm="Are you sure you want to delete this post?"
                      disabled={@loading}
                      class="text-red-600 hover:text-red-900 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Bulk operation helpers

  defp perform_bulk_status_change(socket, post_ids, new_status) do
    results =
      Enum.map(post_ids, fn id ->
        post = Blog.get_post!(id)
        Blog.update_post(post, %{status: new_status})
      end)

    {successes, failures} = Enum.split_with(results, fn {status, _} -> status == :ok end)

    # Update streams for successful changes
    updated_socket =
      Enum.reduce(successes, socket, fn {:ok, updated_post}, acc_socket ->
        updated_post_with_category = Website.Repo.preload(updated_post, :category)
        stream_insert(acc_socket, :posts, updated_post_with_category)
      end)

    success_count = length(successes)
    failure_count = length(failures)

    final_socket =
      updated_socket
      |> assign(:loading, false)
      |> assign(:selected_posts, MapSet.new())

    cond do
      failure_count == 0 ->
        status_text = if new_status == :published, do: "published", else: "drafted"

        final_socket =
          put_flash(final_socket, :info, "#{success_count} posts #{status_text} successfully")

        {:noreply, final_socket}

      success_count == 0 ->
        final_socket =
          put_flash(final_socket, :error, "Failed to update all #{failure_count} posts")

        {:noreply, final_socket}

      true ->
        status_text = if new_status == :published, do: "published", else: "drafted"

        final_socket =
          put_flash(
            final_socket,
            :warning,
            "#{success_count} posts #{status_text}, #{failure_count} failed"
          )

        {:noreply, final_socket}
    end
  end

  defp perform_bulk_delete(socket, post_ids) do
    results =
      Enum.map(post_ids, fn id ->
        post = Blog.get_post!(id)
        Blog.delete_post(post)
      end)

    {successes, failures} = Enum.split_with(results, fn {status, _} -> status == :ok end)

    # Remove successful deletions from streams
    updated_socket =
      Enum.reduce(successes, socket, fn {:ok, deleted_post}, acc_socket ->
        stream_delete(acc_socket, :posts, deleted_post)
      end)

    success_count = length(successes)
    failure_count = length(failures)

    final_socket =
      updated_socket
      |> assign(:loading, false)
      |> assign(:selected_posts, MapSet.new())

    cond do
      failure_count == 0 ->
        final_socket =
          put_flash(final_socket, :info, "#{success_count} posts deleted successfully")

        {:noreply, final_socket}

      success_count == 0 ->
        final_socket =
          put_flash(final_socket, :error, "Failed to delete all #{failure_count} posts")

        {:noreply, final_socket}

      true ->
        final_socket =
          put_flash(
            final_socket,
            :warning,
            "#{success_count} posts deleted, #{failure_count} failed"
          )

        {:noreply, final_socket}
    end
  end

  # Helper functions for data processing

  defp normalize_filters(filters) do
    %{
      title: Map.get(filters, "title", ""),
      category_id: parse_integer(Map.get(filters, "category_id", "")),
      status: parse_status(Map.get(filters, "status", ""))
    }
  end

  defp parse_integer(""), do: nil

  defp parse_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> nil
    end
  end

  defp parse_integer(value) when is_integer(value), do: value
  defp parse_integer(_), do: nil

  defp parse_status(""), do: nil
  defp parse_status("draft"), do: :draft
  defp parse_status("published"), do: :published
  defp parse_status(status) when is_atom(status), do: status
  defp parse_status(_), do: nil

  # Private component functions for render breakdown

  defp render_header(assigns) do
    ~H"""
    <div class="bg-white shadow-sm border-b border-slate-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="py-6 flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-slate-900">Blog Posts</h1>
            <p class="mt-2 text-slate-600">Manage your blog posts and content</p>
          </div>
          <div class="flex items-center gap-4">
            <.link
              navigate="/admin/blog/new"
              class="inline-flex items-center px-4 py-2 bg-emerald-600 text-white font-semibold rounded-lg shadow hover:bg-emerald-700 transition-colors"
            >
              <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                />
              </svg>
              New Post
            </.link>
            <.link
              navigate="/admin/categories"
              class="inline-flex items-center px-4 py-2 bg-orange-600 text-white font-semibold rounded-lg shadow hover:bg-orange-700 transition-colors"
            >
              <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"
                />
              </svg>
              Categories
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
    """
  end

  attr :selected_posts, :any, required: true
  attr :loading, :boolean, required: true

  defp render_bulk_actions(assigns) do
    assigns = assign(assigns, :selected_count, MapSet.size(assigns.selected_posts))

    ~H"""
    <!-- Bulk Actions -->
    <div
      :if={@selected_count > 0}
      class="bulk-actions bg-emerald-50 border border-emerald-200 rounded-lg p-4 mb-6"
    >
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-2">
          <svg class="h-5 w-5 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          <span class="text-sm font-medium text-emerald-800">
            <%= @selected_count %> post<%= if @selected_count != 1, do: "s" %> selected
          </span>
        </div>

        <div class="flex items-center gap-2">
          <button
            phx-click="bulk_action"
            phx-value-action="publish"
            phx-disable-with="Publishing..."
            disabled={@loading}
            class="inline-flex items-center px-3 py-1.5 text-xs font-medium text-green-700 bg-green-100 border border-green-300 rounded-md hover:bg-green-200 disabled:opacity-50"
          >
            <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M5 13l4 4L19 7"
              />
            </svg>
            Publish
          </button>

          <button
            phx-click="bulk_action"
            phx-value-action="draft"
            phx-disable-with="Setting to draft..."
            disabled={@loading}
            class="inline-flex items-center px-3 py-1.5 text-xs font-medium text-yellow-700 bg-yellow-100 border border-yellow-300 rounded-md hover:bg-yellow-200 disabled:opacity-50"
          >
            <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"
              />
            </svg>
            Draft
          </button>

          <button
            phx-click="bulk_action"
            phx-value-action="delete"
            phx-disable-with="Deleting..."
            data-confirm="Are you sure you want to delete the selected posts? This action cannot be undone."
            disabled={@loading}
            class="inline-flex items-center px-3 py-1.5 text-xs font-medium text-red-700 bg-red-100 border border-red-300 rounded-md hover:bg-red-200 disabled:opacity-50"
          >
            <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
              />
            </svg>
            Delete
          </button>

          <button
            phx-click="deselect_all"
            class="inline-flex items-center px-3 py-1.5 text-xs font-medium text-slate-700 bg-white border border-slate-300 rounded-md hover:bg-slate-50"
          >
            Clear Selection
          </button>
        </div>
      </div>
    </div>
    """
  end

  attr :filters, :map, required: true
  attr :categories, :list, required: true

  defp render_filters(assigns) do
    ~H"""
    <!-- Filters -->
    <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6 mb-6">
      <h3 class="text-lg font-medium text-slate-900 mb-4">Filters</h3>
      <.form for={%{}} id="filter-form" phx-change="filter" phx-submit="filter">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-1">Title</label>
            <input
              type="text"
              name="filters[title]"
              value={@filters.title}
              placeholder="Search by title..."
              class="w-full rounded-md border-slate-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-1">Category</label>
            <select
              name="filters[category_id]"
              value={@filters.category_id || ""}
              class="w-full rounded-md border-slate-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
            >
              <option value="">All Categories</option>
              <option
                :for={category <- @categories}
                value={category.id}
                selected={category.id == @filters.category_id}
              >
                <%= category.name %>
              </option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-1">Status</label>
            <select
              name="filters[status]"
              value={(@filters.status && to_string(@filters.status)) || ""}
              class="w-full rounded-md border-slate-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
            >
              <option value="">All Status</option>
              <option value="draft" selected={@filters.status == :draft}>Draft</option>
              <option value="published" selected={@filters.status == :published}>Published</option>
            </select>
          </div>
        </div>
      </.form>
    </div>
    """
  end
end
