defmodule WebsiteWeb.AdminPhotosLive do
  use WebsiteWeb, :live_view

  alias Website.{Photo, PhotoCategory, Gallery, Repo}
  import Ecto.Query

  @uploads_dir "priv/static/images"

  def mount(_params, _session, socket) do
    photos = Gallery.list_photos_by_date()
    categories = Gallery.list_photo_categories()

    socket =
      socket
      |> stream(:photos, photos)
      |> assign(:categories, categories)
      |> assign(:changeset, Photo.changeset(%Photo{}, %{}))
      |> assign(:editing_photo, nil)
      |> assign(:category_changeset, nil)
      |> allow_upload(:image, accept: ~w(.jpg .jpeg .png .gif), max_entries: 1)

    {:ok, socket}
  end

  def handle_event("validate", %{"photo" => photo_params}, socket) do
    changeset = Photo.changeset(%Photo{}, photo_params)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"photo" => photo_params}, socket) do
    case consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
           filename = "#{System.unique_integer([:positive])}_#{entry.client_name}"
           dest = Path.join([@uploads_dir, filename])

           File.mkdir_p!(Path.dirname(dest))
           File.cp!(path, dest)

           {:ok, "/images/#{filename}"}
         end) do
      [image_path] ->
        photo_params = Map.put(photo_params, "image_path", image_path)

        case Gallery.create_photo(photo_params) do
          {:ok, photo} ->
            photo = Repo.preload(photo, :photo_category)
            
            socket =
              socket
              |> stream_insert(:photos, photo, at: 0)
              |> assign(:changeset, Photo.changeset(%Photo{}, %{}))
              |> put_flash(:info, "Photo uploaded successfully!")

            {:noreply, socket}

          {:error, changeset} ->
            # Log the error for debugging
            require Logger
            Logger.error("Failed to create photo: #{inspect(changeset.errors)}")
            Logger.error("Photo params: #{inspect(photo_params)}")
            
            {:noreply, assign(socket, :changeset, changeset)}
        end

      [] ->
        {:noreply, put_flash(socket, :error, "Please select an image to upload")}
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    photo = Repo.get!(Photo, id) |> Repo.preload(:photo_category)
    changeset = Photo.changeset(photo, %{})

    socket =
      socket
      |> assign(:editing_photo, photo)
      |> assign(:changeset, changeset)

    {:noreply, socket}
  end

  def handle_event("update", %{"photo" => photo_params}, socket) do
    photo = socket.assigns.editing_photo

    case Gallery.update_photo(photo, photo_params) do
      {:ok, updated_photo} ->
        updated_photo = Repo.preload(updated_photo, :photo_category)
        
        socket =
          socket
          |> stream_insert(:photos, updated_photo)
          |> assign(:editing_photo, nil)
          |> assign(:changeset, Photo.changeset(%Photo{}, %{}))
          |> put_flash(:info, "Photo updated successfully!")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("cancel_edit", _params, socket) do
    socket =
      socket
      |> assign(:editing_photo, nil)
      |> assign(:changeset, Photo.changeset(%Photo{}, %{}))

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    photo = Repo.get!(Photo, id)

    # Delete the image file if it exists
    if photo.image_path do
      file_path = Path.join("priv/static", String.trim_leading(photo.image_path, "/"))
      File.rm(file_path)
    end

    Repo.delete!(photo)

    socket =
      socket
      |> stream_delete(:photos, photo)
      |> put_flash(:info, "Photo deleted successfully!")

    {:noreply, socket}
  end

  def handle_event("new_category", _params, socket) do
    changeset = PhotoCategory.create_changeset(%PhotoCategory{}, %{})

    socket =
      socket
      |> assign(:category_changeset, changeset)

    {:noreply, socket}
  end

  def handle_event("validate_category", %{"photo_category" => category_params}, socket) do
    changeset = PhotoCategory.create_changeset(%PhotoCategory{}, category_params)
    {:noreply, assign(socket, :category_changeset, changeset)}
  end

  def handle_event("create_category", %{"photo_category" => category_params}, socket) do
    case Gallery.create_photo_category(category_params) do
      {:ok, _category} ->
        categories = Gallery.list_photo_categories()

        socket =
          socket
          |> assign(:categories, categories)
          |> assign(:category_changeset, nil)
          |> put_flash(:info, "Category created successfully!")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :category_changeset, changeset)}
    end
  end

  def handle_event("cancel_category", _params, socket) do
    socket =
      socket
      |> assign(:category_changeset, nil)

    {:noreply, socket}
  end

  def handle_event("delete_category", %{"id" => id}, socket) do
    category = Gallery.get_photo_category_by_slug(id) || Repo.get!(PhotoCategory, id)

    # First, unlink all photos from this category (set photo_category_id to nil)
    from(p in Photo, where: p.photo_category_id == ^category.id)
    |> Repo.update_all(set: [photo_category_id: nil])

    # Then delete the category
    Repo.delete!(category)

    # Refresh data
    categories = Gallery.list_photo_categories()
    photos = Gallery.list_photos_by_date()

    socket =
      socket
      |> assign(:categories, categories)
      |> stream(:photos, photos, reset: true)
      |> put_flash(:info, "Category deleted successfully! Photos have been uncategorized.")

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-50">
      <div class="bg-white shadow-sm border-b border-slate-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="py-6 flex items-center justify-between">
            <div>
              <h1 class="text-3xl font-bold text-slate-900">Photo Gallery Management</h1>
              <p class="mt-2 text-slate-600">Upload and manage gallery photos</p>
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
        <.render_category_management
          categories={@categories}
          category_changeset={@category_changeset}
        />
        <!-- Upload Form -->
        <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6 mb-8">
          <h2 class="text-xl font-semibold text-slate-900 mb-4">Upload New Photo</h2>

          <.form :let={f} for={@changeset} phx-submit="save" phx-change="validate">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label class="block text-sm font-medium text-slate-700 mb-2">Image</label>
                <div class="border-2 border-dashed border-slate-300 rounded-lg p-6 text-center">
                  <.live_file_input
                    upload={@uploads.image}
                    class="block w-full text-sm text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:bg-slate-50 file:text-slate-700 hover:file:bg-slate-100"
                  />
                </div>
                <div :for={entry <- @uploads.image.entries} class="mt-2">
                  <div class="bg-slate-100 rounded p-2 text-sm">
                    <%= entry.client_name %> (<%= entry.progress %>%)
                  </div>
                </div>
              </div>

              <div>
                <label class="block text-sm font-medium text-slate-700 mb-2">Description</label>
                <.input field={f[:description]} type="textarea" rows="3" />

                <label class="block text-sm font-medium text-slate-700 mb-2 mt-4">Category</label>
                <.input
                  field={f[:photo_category_id]}
                  type="select"
                  options={[{"Select a category...", nil} | Enum.map(@categories, &{&1.name, &1.id})]}
                />
              </div>
            </div>

            <div class="mt-6 flex justify-end">
              <button
                type="submit"
                class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700"
              >
                Upload Photo
              </button>
            </div>
          </.form>
        </div>
        <!-- Edit Form (shows when editing) -->
        <div
          :if={@editing_photo}
          class="bg-white rounded-lg shadow-sm border border-slate-200 p-6 mb-8"
        >
          <h2 class="text-xl font-semibold text-slate-900 mb-4">Edit Photo</h2>

          <.form :let={f} for={@changeset} phx-submit="update">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <img
                  src={@editing_photo.image_path}
                  alt={@editing_photo.description}
                  class="w-full h-48 object-cover rounded-lg"
                />
              </div>

              <div>
                <label class="block text-sm font-medium text-slate-700 mb-2">Description</label>
                <.input field={f[:description]} type="textarea" rows="3" />

                <label class="block text-sm font-medium text-slate-700 mb-2 mt-4">Category</label>
                <.input
                  field={f[:photo_category_id]}
                  type="select"
                  options={[{"Select a category...", nil} | Enum.map(@categories, &{&1.name, &1.id})]}
                />
              </div>
            </div>

            <div class="mt-6 flex justify-end gap-2">
              <button
                type="button"
                phx-click="cancel_edit"
                class="bg-slate-600 text-white px-6 py-2 rounded-lg hover:bg-slate-700"
              >
                Cancel
              </button>
              <button
                type="submit"
                class="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700"
              >
                Update Photo
              </button>
            </div>
          </.form>
        </div>
        <!-- Photos Grid -->
        <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
          <h2 class="text-xl font-semibold text-slate-900 mb-6">
            Existing Photos (<%= Enum.count(@streams.photos) %>)
          </h2>

          <div :if={@streams.photos == []} class="text-center py-12 text-slate-500">
            No photos uploaded yet. Upload your first photo above!
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <div
              :for={{id, photo} <- @streams.photos}
              id={id}
              class="border border-slate-200 rounded-lg overflow-hidden"
            >
              <img src={photo.image_path} alt={photo.description} class="w-full h-48 object-cover" />

              <div class="p-4">
                <p class="text-sm font-medium text-slate-900 mb-2"><%= photo.description %></p>
                <p class="text-xs text-slate-500 mb-3">
                  Category: <%= if photo.photo_category,
                    do: photo.photo_category.name,
                    else: "Uncategorized" %>
                </p>

                <div class="flex gap-2">
                  <button
                    phx-click="edit"
                    phx-value-id={photo.id}
                    class="text-sm bg-slate-100 text-slate-700 px-3 py-1 rounded hover:bg-slate-200"
                  >
                    Edit
                  </button>
                  <button
                    phx-click="delete"
                    phx-value-id={photo.id}
                    data-confirm="Are you sure you want to delete this photo?"
                    class="text-sm bg-red-100 text-red-700 px-3 py-1 rounded hover:bg-red-200"
                  >
                    Delete
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Private component functions for render breakdown

  attr :categories, :list, required: true
  attr :category_changeset, :any, default: nil

  defp render_category_management(assigns) do
    ~H"""
    <!-- Category Management -->
    <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6 mb-8">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-xl font-semibold text-slate-900">Photo Categories</h2>
        <button
          phx-click="new_category"
          class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700"
        >
          New Category
        </button>
      </div>

      <div :if={@category_changeset} class="border border-slate-300 rounded-lg p-4 mb-4 bg-slate-50">
        <h3 class="text-lg font-medium text-slate-900 mb-3">Create New Category</h3>

        <.form
          :let={f}
          for={@category_changeset}
          phx-submit="create_category"
          phx-change="validate_category"
        >
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 mb-1">Name</label>
              <.input field={f[:name]} type="text" placeholder="e.g., Travel" />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 mb-1">Description</label>
              <.input field={f[:description]} type="text" placeholder="Brief description" />
            </div>
            <div>
              <label class="block text-sm font-medium text-slate-700 mb-1">Color</label>
              <.input field={f[:color]} type="color" value="#10b981" />
            </div>
          </div>

          <div class="mt-4 flex gap-2">
            <button
              type="submit"
              class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700"
            >
              Create Category
            </button>
            <button
              type="button"
              phx-click="cancel_category"
              class="bg-slate-600 text-white px-4 py-2 rounded-lg hover:bg-slate-700"
            >
              Cancel
            </button>
          </div>
        </.form>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-4">
        <div :for={category <- @categories} class="border border-slate-200 rounded-lg p-4">
          <div class="flex items-center justify-between mb-2">
            <div class="flex items-center gap-3">
              <div class="w-4 h-4 rounded-full" style={"background-color: #{category.color}"}></div>
              <h3 class="font-medium text-slate-900"><%= category.name %></h3>
            </div>
            <button
              phx-click="delete_category"
              phx-value-id={category.id}
              data-confirm="Are you sure? This will uncategorize all photos in this category."
              class="text-red-500 hover:text-red-700 text-sm"
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
          <p class="text-sm text-slate-600"><%= category.description %></p>
        </div>
      </div>
    </div>
    """
  end
end
