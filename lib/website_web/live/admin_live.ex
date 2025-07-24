defmodule WebsiteWeb.AdminLive do
  use WebsiteWeb, :live_view

  alias Website.{Blog, Projects, Gallery, Repo}

  def mount(_params, _session, socket) do
    # Get counts for dashboard stats using optimized database aggregates
    project_count = Repo.aggregate(Projects.Project, :count, :id)
    photo_count = Gallery.count_photos()
    blog_count = Blog.count_published_posts()

    socket =
      socket
      |> assign(:current_path, "/admin")
      |> assign(:project_count, project_count)
      |> assign(:photo_count, photo_count)
      |> assign(:blog_count, blog_count)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-50">
      <div class="bg-white shadow-sm border-b border-slate-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="py-6">
            <h1 class="text-3xl font-bold text-slate-900">Admin Panel</h1>
            <p class="mt-2 text-slate-600">Welcome to the admin dashboard</p>
          </div>
        </div>
      </div>

      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Quick Stats -->
        <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6 mb-8">
          <h2 class="text-xl font-semibold text-slate-900 mb-4">Quick Overview</h2>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div class="text-center">
              <div class="text-2xl font-bold text-emerald-600"><%= @blog_count %></div>
              <div class="text-sm text-slate-500">Blog Posts</div>
            </div>
            <div class="text-center">
              <div class="text-2xl font-bold text-blue-600"><%= @photo_count %></div>
              <div class="text-sm text-slate-500">Photos</div>
            </div>
            <div class="text-center">
              <div class="text-2xl font-bold text-purple-600"><%= @project_count %></div>
              <div class="text-sm text-slate-500">Projects</div>
            </div>
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <!-- Blog Management Card -->
          <.link navigate="/admin/blog" class="block">
            <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6 hover:shadow-md transition-shadow">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <svg class="h-8 w-8 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C20.832 18.477 19.246 18 17.5 18c-1.746 0-3.332.477-4.5 1.253" />
                  </svg>
                </div>
                <div class="ml-4">
                  <h3 class="text-lg font-medium text-slate-900">Blog Posts</h3>
                  <p class="text-sm text-slate-500">Manage blog content</p>
                </div>
              </div>
              <div class="mt-4">
                <p class="text-sm text-slate-600">Create, edit, and manage blog posts.</p>
              </div>
            </div>
          </.link>

          <!-- Categories Management Card -->
          <.link navigate="/admin/categories" class="block">
            <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6 hover:shadow-md transition-shadow">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <svg class="h-8 w-8 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
                  </svg>
                </div>
                <div class="ml-4">
                  <h3 class="text-lg font-medium text-slate-900">Categories</h3>
                  <p class="text-sm text-slate-500">Manage blog categories</p>
                </div>
              </div>
              <div class="mt-4">
                <p class="text-sm text-slate-600">Create and organize blog post categories.</p>
              </div>
            </div>
          </.link>

          <!-- Photo Gallery Card -->
          <.link navigate="/admin/photos" class="block">
            <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6 hover:shadow-md transition-shadow">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <svg class="h-8 w-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                  </svg>
                </div>
                <div class="ml-4">
                  <h3 class="text-lg font-medium text-slate-900">Photo Gallery</h3>
                  <p class="text-sm text-slate-500">Manage photos</p>
                </div>
              </div>
              <div class="mt-4">
                <p class="text-sm text-slate-600">Upload and organize images for the photo collage in About Me.</p>
              </div>
            </div>
          </.link>

          <!-- Projects Management Card -->
          <.link navigate="/admin/projects" class="block">
            <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6 hover:shadow-md transition-shadow">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <svg class="h-8 w-8 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
                  </svg>
                </div>
                <div class="ml-4">
                  <h3 class="text-lg font-medium text-slate-900">Projects</h3>
                  <p class="text-sm text-slate-500">Manage portfolio projects</p>
                </div>
              </div>
              <div class="mt-4">
                <p class="text-sm text-slate-600">Create, edit, and manage portfolio projects and technologies.</p>
              </div>
            </div>
          </.link>
        </div>
      </div>
    </div>
    """
  end
end
