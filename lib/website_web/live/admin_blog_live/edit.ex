defmodule WebsiteWeb.AdminBlogLive.Edit do
  use WebsiteWeb, :live_view

  alias Website.Blog

  @blog_uploads_dir "priv/static/images/blog/uploads"

  def mount(%{"id" => id}, _session, socket) do
    post = Blog.get_post!(id)
    categories = Blog.list_categories()
    changeset = Blog.change_post(post)

    socket =
      socket
      |> assign(:current_path, "/admin/blog/edit/#{id}")
      |> assign(:post, post)
      |> assign(:changeset, changeset)
      |> assign(:categories, categories)
      |> allow_upload(:featured_image,
        accept: ~w(.jpg .jpeg .png .gif),
        max_entries: 1,
        max_file_size: 5_000_000
      )

    {:ok, socket}
  end

  def handle_event("validate", %{"post" => post_params}, socket) do
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

    # Add image path to post params if an image was uploaded, otherwise keep existing
    final_post_params =
      case uploaded_files do
        [image_path] -> Map.put(post_params, "image_path", image_path)
        [] -> post_params
      end

    case Blog.update_post(socket.assigns.post, final_post_params) do
      {:ok, post} ->
        socket =
          socket
          |> put_flash(:info, "Post updated successfully")
          |> assign(:post, post)
          |> assign(:changeset, Blog.change_post(post))

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, :changeset, changeset)
        {:noreply, socket}
    end
  end

  def handle_event("delete", _params, socket) do
    case Blog.delete_post(socket.assigns.post) do
      {:ok, _post} ->
        socket =
          socket
          |> put_flash(:info, "Post deleted successfully")
          |> push_navigate(to: ~p"/admin/blog")

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
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="py-6 flex items-center justify-between">
            <div>
              <nav class="flex items-center space-x-2 text-sm text-slate-500 mb-4">
                <.link navigate="/admin" class="hover:text-slate-700">Admin</.link>
                <span>/</span>
                <.link navigate="/admin/blog" class="hover:text-slate-700">Blog</.link>
                <span>/</span>
                <span class="text-slate-900">Edit Post</span>
              </nav>
              <div>
                <h1 class="text-3xl font-bold text-slate-900">Edit Post</h1>
                <p class="mt-2 text-slate-600">Update your blog post content</p>
              </div>
            </div>
            <div class="flex items-center space-x-3">
              <.link
                navigate={~p"/blog/posts/#{@post.id}"}
                target="_blank"
                class="text-sm text-blue-600 hover:text-blue-800 font-medium"
              >
                View Post →
              </.link>
              <button
                phx-click="delete"
                data-confirm="Are you sure you want to delete this post? This action cannot be undone."
                class="inline-flex items-center px-3 py-2 border border-red-300 rounded-md text-sm font-medium text-red-700 bg-white hover:bg-red-50"
              >
                Delete Post
              </button>
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

      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Post Meta Information -->
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
            <div>
              <span class="font-medium text-blue-900">Created:</span>
              <span class="text-blue-700">
                <%= Calendar.strftime(@post.inserted_at, "%B %d, %Y at %I:%M %p") %>
              </span>
            </div>
            <div>
              <span class="font-medium text-blue-900">Updated:</span>
              <span class="text-blue-700">
                <%= Calendar.strftime(@post.updated_at, "%B %d, %Y at %I:%M %p") %>
              </span>
            </div>
            <div>
              <span class="font-medium text-blue-900">Current Status:</span>
              <span class={[
                "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ml-2",
                if(@post.status == :published,
                  do: "bg-green-100 text-green-800",
                  else: "bg-yellow-100 text-yellow-800"
                )
              ]}>
                <%= @post.status |> Atom.to_string() |> String.capitalize() %>
              </span>
            </div>
          </div>
        </div>

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
                  options={Enum.map(@categories, &{&1.name, &1.id})}
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
                <!-- Current Image Preview -->
                <%= if @post.image_path do %>
                  <div class="mb-4 p-4 bg-slate-50 rounded-lg">
                    <p class="text-sm font-medium text-slate-700 mb-2">Current Image:</p>
                    <img
                      src={@post.image_path}
                      alt="Current featured image"
                      class="max-w-xs h-32 object-cover rounded border"
                    />
                    <p class="text-xs text-slate-500 mt-1"><%= @post.image_path %></p>
                  </div>
                <% end %>

                <div class="border-2 border-dashed border-slate-300 rounded-lg p-6 text-center">
                  <.live_file_input
                    upload={@uploads.featured_image}
                    class="block w-full text-sm text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:bg-slate-50 file:text-slate-700 hover:file:bg-slate-100"
                  />
                  <p class="mt-2 text-xs text-slate-500">
                    Upload JPG, PNG, or GIF to replace current image (recommended size: 1200x630px)
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
                    Or update image path manually
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
              <!-- Read Time (Display Only) -->
              <div class="lg:col-span-2">
                <label class="block text-sm font-medium text-slate-700 mb-2">
                  Read Time (Auto-calculated)
                </label>
                <div class="px-3 py-2 bg-slate-50 border border-slate-300 rounded-md text-sm text-slate-600">
                  <%= @post.read_time %> minutes
                </div>
                <p class="mt-1 text-xs text-slate-500">
                  Based on ~200 words per minute reading speed
                </p>
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
              ← Back to Blog Posts
            </.link>

            <button
              type="submit"
              class="inline-flex items-center px-6 py-2 bg-emerald-600 text-white font-medium rounded-md shadow-sm hover:bg-emerald-700"
            >
              Update Post
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
