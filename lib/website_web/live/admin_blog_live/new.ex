defmodule WebsiteWeb.AdminBlogLive.New do
  use WebsiteWeb, :live_view

  alias Website.Blog.{Posts, Categories, Post}

  def mount(_params, _session, socket) do
    categories = Categories.list_categories()
    changeset = Posts.change_post(%Post{})

    socket =
      socket
      |> assign(:current_path, "/admin/blog/new")
      |> assign(:changeset, changeset)
      |> assign(:categories, categories)
      |> assign(:post, %Post{})

    {:ok, socket}
  end

  def handle_event("validate", %{"post" => post_params}, socket) do
    # Skip validation for trix-change events to prevent editor disappearing
    changeset =
      socket.assigns.post
      |> Posts.change_post(post_params)
      |> Map.put(:action, :validate)

    socket = assign(socket, :changeset, changeset)
    {:noreply, socket}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    case Posts.create_post(post_params) do
      {:ok, post} ->
        socket =
          socket
          |> put_flash(:info, "Post created successfully")
          |> push_navigate(to: ~p"/admin/blog/edit/#{post.id}")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, :changeset, changeset)
        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-50">
      <div class="bg-white shadow-sm border-b border-slate-200">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="py-6">
            <nav class="flex items-center space-x-2 text-sm text-slate-500 mb-4">
              <.link navigate="/admin" class="hover:text-slate-700">Admin</.link>
              <span>/</span>
              <.link navigate="/admin/blog" class="hover:text-slate-700">Blog</.link>
              <span>/</span>
              <span class="text-slate-900">New Post</span>
            </nav>
            <h1 class="text-3xl font-bold text-slate-900">Create New Post</h1>
            <p class="mt-2 text-slate-600">Write and publish a new blog post</p>
          </div>
        </div>
      </div>

      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <.form :let={f} for={@changeset} phx-change="validate" phx-submit="save" class="space-y-6">
          <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <!-- Title -->
              <div class="lg:col-span-2">
                <label class="block text-sm font-medium text-slate-700 mb-2">
                  Title <span class="text-red-500">*</span>
                </label>
                <.input 
                  field={f[:title]} 
                  type="text" 
                  placeholder="Enter post title..."
                />
              </div>

              <!-- Slug -->
              <div>
                <label class="block text-sm font-medium text-slate-700 mb-2">
                  Slug <span class="text-red-500">*</span>
                </label>
                <.input 
                  field={f[:slug]} 
                  type="text" 
                  placeholder="auto-generated-from-title"
                />
                <p class="mt-1 text-xs text-slate-500">URL-friendly version of the title</p>
              </div>

              <!-- Category -->
              <div>
                <label class="block text-sm font-medium text-slate-700 mb-2">
                  Category <span class="text-red-500">*</span>
                </label>
                <.input 
                  field={f[:category_id]} 
                  type="select" 
                  options={[{"Select a category", ""} | Enum.map(@categories, &{&1.name, &1.id})]}
                />
              </div>

              <!-- Description -->
              <div class="lg:col-span-2">
                <label class="block text-sm font-medium text-slate-700 mb-2">
                  Description <span class="text-red-500">*</span>
                </label>
                <.input 
                  field={f[:description]} 
                  type="textarea" 
                  rows="3"
                  placeholder="Brief description for SEO and preview..."
                />
                <p class="mt-1 text-xs text-slate-500">This appears in search results and post previews</p>
              </div>

              <!-- Image Path -->
              <div>
                <label class="block text-sm font-medium text-slate-700 mb-2">
                  Featured Image Path <span class="text-red-500">*</span>
                </label>
                <.input 
                  field={f[:image_path]} 
                  type="text" 
                  placeholder="/images/blog/my-post.jpg"
                />
              </div>

              <!-- Status -->
              <div>
                <label class="block text-sm font-medium text-slate-700 mb-2">
                  Status
                </label>
                <.input 
                  field={f[:status]} 
                  type="select" 
                  options={[{"Draft", "draft"}, {"Published", "published"}]}
                />
              </div>
            </div>
          </div>

          <!-- Body Content -->
          <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
            <.trix_editor 
              field={f[:body]}
              label="Content *"
              placeholder="Write your post content here..."
            />
          </div>

          <!-- Action Buttons -->
          <div class="flex items-center justify-between">
            <.link navigate="/admin/blog" class="inline-flex items-center px-4 py-2 border border-slate-300 rounded-md shadow-sm text-sm font-medium text-slate-700 bg-white hover:bg-slate-50">
              Cancel
            </.link>
            
            <button 
              type="submit"
              class="inline-flex items-center px-6 py-2 bg-emerald-600 text-white font-medium rounded-md shadow-sm hover:bg-emerald-700"
            >
              Create Post
            </button>
          </div>
        </.form>
      </div>
    </div>
    """
  end
end