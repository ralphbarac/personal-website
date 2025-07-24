defmodule WebsiteWeb.AdminBlogLive do
  use WebsiteWeb, :live_view

  alias Website.Blog.{Posts, Categories}

  def mount(_params, _session, socket) do
    posts = Posts.list_posts_admin()
    categories = Categories.list_categories()

    socket =
      socket
      |> assign(:current_path, "/admin/blog")
      |> assign(:posts, posts)
      |> assign(:categories, categories)
      |> assign(:filters, %{title: "", category_id: "", status: ""})

    {:ok, socket}
  end

  def handle_event("filter", %{"filters" => filters}, socket) do
    filtered_posts = Posts.list_posts_admin(filters)
    
    socket =
      socket
      |> assign(:posts, filtered_posts)
      |> assign(:filters, filters)

    {:noreply, socket}
  end

  def handle_event("toggle_status", %{"id" => id}, socket) do
    post = Posts.get_post!(id)
    
    case Posts.toggle_post_status(post) do
      {:ok, _post} ->
        posts = Posts.list_posts_admin(socket.assigns.filters)
        socket = 
          socket
          |> assign(:posts, posts)
          |> put_flash(:info, "Post status updated successfully")
        {:noreply, socket}
      
      {:error, _changeset} ->
        socket = put_flash(socket, :error, "Failed to update post status")
        {:noreply, socket}
    end
  end

  def handle_event("delete_post", %{"id" => id}, socket) do
    post = Posts.get_post!(id)
    
    case Posts.delete_post(post) do
      {:ok, _post} ->
        posts = Posts.list_posts_admin(socket.assigns.filters)
        socket = 
          socket
          |> assign(:posts, posts)
          |> put_flash(:info, "Post deleted successfully")
        {:noreply, socket}
      
      {:error, _changeset} ->
        socket = put_flash(socket, :error, "Failed to delete post")
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
              <h1 class="text-3xl font-bold text-slate-900">Blog Posts</h1>
              <p class="mt-2 text-slate-600">Manage your blog posts and content</p>
            </div>
            <.link navigate="/admin/blog/new" class="inline-flex items-center px-4 py-2 bg-emerald-600 text-white font-semibold rounded-lg shadow hover:bg-emerald-700 transition-colors">
              <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
              </svg>
              New Post
            </.link>
          </div>
        </div>
      </div>

      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Filters -->
        <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6 mb-6">
          <h3 class="text-lg font-medium text-slate-900 mb-4">Filters</h3>
          <.form for={%{}} phx-change="filter" phx-submit="filter">
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
                  class="w-full rounded-md border-slate-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
                >
                  <option value="">All Categories</option>
                  <option :for={category <- @categories} value={category.id} selected={category.id == @filters.category_id}>
                    <%= category.name %>
                  </option>
                </select>
              </div>
              <div>
                <label class="block text-sm font-medium text-slate-700 mb-1">Status</label>
                <select 
                  name="filters[status]" 
                  class="w-full rounded-md border-slate-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
                >
                  <option value="">All Status</option>
                  <option value="draft" selected={@filters.status == "draft"}>Draft</option>
                  <option value="published" selected={@filters.status == "published"}>Published</option>
                </select>
              </div>
            </div>
          </.form>
        </div>

        <!-- Posts Table -->
        <div class="bg-white rounded-lg shadow-sm border border-slate-200 overflow-hidden">
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-slate-200">
              <thead class="bg-slate-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Title</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Category</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Status</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Read Time</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Created</th>
                  <th class="px-6 py-3 text-right text-xs font-medium text-slate-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-slate-200">
                <tr :for={post <- @posts} class="hover:bg-slate-50">
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="text-sm font-medium text-slate-900"><%= post.title %></div>
                    <div class="text-sm text-slate-500 truncate max-w-xs"><%= post.description %></div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                      <%= post.category.name %>
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span class={[
                      "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium",
                      if(post.status == "published", do: "bg-green-100 text-green-800", else: "bg-yellow-100 text-yellow-800")
                    ]}>
                      <%= String.capitalize(post.status) %>
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-500">
                    <%= post.read_time %> min
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-500">
                    <%= Calendar.strftime(post.inserted_at, "%b %d, %Y") %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-2">
                    <.link navigate={~p"/admin/blog/edit/#{post.id}"} class="text-emerald-600 hover:text-emerald-900">
                      Edit
                    </.link>
                    <button 
                      phx-click="toggle_status" 
                      phx-value-id={post.id}
                      class="text-blue-600 hover:text-blue-900"
                    >
                      <%= if post.status == "published", do: "Unpublish", else: "Publish" %>
                    </button>
                    <button 
                      phx-click="delete_post" 
                      phx-value-id={post.id}
                      data-confirm="Are you sure you want to delete this post?"
                      class="text-red-600 hover:text-red-900"
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <%= if Enum.empty?(@posts) do %>
            <div class="text-center py-12">
              <svg class="mx-auto h-12 w-12 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C20.832 18.477 19.246 18 17.5 18c-1.746 0-3.332.477-4.5 1.253"/>
              </svg>
              <h3 class="mt-2 text-sm font-medium text-slate-900">No posts found</h3>
              <p class="mt-1 text-sm text-slate-500">Get started by creating your first blog post.</p>
              <div class="mt-6">
                <.link navigate="/admin/blog/new" class="inline-flex items-center px-4 py-2 bg-emerald-600 text-white font-semibold rounded-lg shadow hover:bg-emerald-700 transition-colors">
                  <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
                  </svg>
                  New Post
                </.link>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end