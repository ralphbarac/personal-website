defmodule WebsiteWeb.AdminBlogLive.New do
  use WebsiteWeb, :live_view

  alias Website.Blog
  alias Website.Blog.Post

  @blog_uploads_dir "priv/static/images/blog/uploads"

  def mount(_params, _session, socket) do
    categories = Blog.list_categories()
    changeset = Blog.change_post(%Post{})

    socket =
      socket
      |> assign(:current_path, "/admin/blog/new")
      |> assign(:changeset, changeset)
      |> assign(:categories, categories)
      |> assign(:post, %Post{})
      |> allow_upload(:featured_image,
        accept: ~w(.jpg .jpeg .png .gif),
        max_entries: 1,
        max_file_size: 5_000_000
      )

    {:ok, socket}
  end

  def handle_event("validate", %{"post" => post_params}, socket) do
    # Skip validation for trix-change events to prevent editor disappearing
    changeset =
      socket.assigns.post
      |> Blog.change_post(post_params)
      |> Map.put(:action, :validate)

    socket = assign(socket, :changeset, changeset)
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :featured_image, ref)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    # Handle image upload
    uploaded_files =
      consume_uploaded_entries(socket, :featured_image, fn %{path: path}, entry ->
        filename = "#{System.unique_integer([:positive])}_#{entry.client_name}"
        dest = Path.join([@blog_uploads_dir, filename])

        File.mkdir_p!(Path.dirname(dest))
        File.cp!(path, dest)

        {:ok, "/images/blog/uploads/#{filename}"}
      end)

    # Add image path to post params if an image was uploaded
    final_post_params =
      case uploaded_files do
        [image_path] -> Map.put(post_params, "image_path", image_path)
        [] -> post_params
      end

    case Blog.create_post(final_post_params) do
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
          <div class="py-6 flex items-center justify-between">
            <div>
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
            <.link
              navigate="/admin"
              class="bg-slate-600 text-white px-4 py-2 rounded-lg hover:bg-slate-700"
            >
              Back to Admin
            </.link>
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
                <.input field={f[:title]} type="text" placeholder="Enter post title..." />
              </div>
              <!-- Slug -->
              <div>
                <label class="block text-sm font-medium text-slate-700 mb-2">
                  Slug <span class="text-red-500">*</span>
                </label>
                <.input field={f[:slug]} type="text" placeholder="auto-generated-from-title" />
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
                <p class="mt-1 text-xs text-slate-500">
                  This appears in search results and post previews
                </p>
              </div>
              <!-- Featured Image Upload -->
              <div class="lg:col-span-2">
                <label class="block text-sm font-medium text-slate-700 mb-2">
                  Featured Image <span class="text-red-500">*</span>
                </label>
                <div class="border-2 border-dashed border-slate-300 rounded-lg p-6 text-center">
                  <.live_file_input
                    upload={@uploads.featured_image}
                    class="block w-full text-sm text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:bg-slate-50 file:text-slate-700 hover:file:bg-slate-100"
                  />
                  <p class="mt-2 text-xs text-slate-500">
                    Upload JPG, PNG, or GIF (recommended size: 1200x630px)
                  </p>
                </div>

                <div :for={entry <- @uploads.featured_image.entries} class="mt-2">
                  <div class="bg-slate-100 rounded p-2 text-sm flex items-center justify-between">
                    <span><%= entry.client_name %> (<%= entry.progress %>%)</span>
                    <button
                      type="button"
                      phx-click="cancel-upload"
                      phx-value-ref={entry.ref}
                      class="text-red-600 hover:text-red-800"
                    >
                      Remove
                    </button>
                  </div>

                  <%= for err <- upload_errors(@uploads.featured_image, entry) do %>
                    <div class="text-red-600 text-sm mt-1"><%= error_to_string(err) %></div>
                  <% end %>
                </div>

                <%= for err <- upload_errors(@uploads.featured_image) do %>
                  <div class="text-red-600 text-sm mt-1"><%= error_to_string(err) %></div>
                <% end %>
                <!-- Fallback: Manual Image Path -->
                <div class="mt-4">
                  <label class="block text-sm font-medium text-slate-700 mb-2">
                    Or enter image path manually (optional)
                  </label>
                  <.input field={f[:image_path]} type="text" placeholder="/images/blog/my-post.jpg" />
                  <p class="mt-1 text-xs text-slate-500">
                    Use this if you prefer to host images elsewhere
                  </p>
                </div>
              </div>
              <!-- Status -->
              <div>
                <label class="block text-sm font-medium text-slate-700 mb-2">
                  Status
                </label>
                <.input
                  field={f[:status]}
                  type="select"
                  options={[{"Draft", :draft}, {"Published", :published}]}
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
            <.link
              navigate="/admin/blog"
              class="inline-flex items-center px-4 py-2 border border-slate-300 rounded-md shadow-sm text-sm font-medium text-slate-700 bg-white hover:bg-slate-50"
            >
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

  defp error_to_string(:too_large), do: "File too large (max 5MB)"
  defp error_to_string(:too_many_files), do: "Too many files (only 1 allowed)"
  defp error_to_string(:not_accepted), do: "Unacceptable file type (only JPG, PNG, GIF allowed)"
  defp error_to_string(error), do: "Upload error: #{inspect(error)}"
end
