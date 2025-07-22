defmodule WebsiteWeb.AdminLive do
  use WebsiteWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :current_path, "/admin")}
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
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <!-- Blog Management Card -->
          <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
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
              <p class="text-sm text-slate-600">Create, edit, and manage blog posts and categories.</p>
            </div>
          </div>

          <!-- Photo Gallery Card -->
          <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
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
              <p class="text-sm text-slate-600">Upload and organize photos for the gallery.</p>
            </div>
          </div>

          <!-- Site Settings Card -->
          <div class="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <svg class="h-8 w-8 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
              </div>
              <div class="ml-4">
                <h3 class="text-lg font-medium text-slate-900">Site Settings</h3>
                <p class="text-sm text-slate-500">Configure site options</p>
              </div>
            </div>
            <div class="mt-4">
              <p class="text-sm text-slate-600">Manage site-wide settings and configurations.</p>
            </div>
          </div>
        </div>

        <!-- Quick Stats -->
        <div class="mt-8 bg-white rounded-lg shadow-sm border border-slate-200 p-6">
          <h2 class="text-xl font-semibold text-slate-900 mb-4">Quick Overview</h2>
          <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div class="text-center">
              <div class="text-2xl font-bold text-emerald-600">-</div>
              <div class="text-sm text-slate-500">Blog Posts</div>
            </div>
            <div class="text-center">
              <div class="text-2xl font-bold text-blue-600">-</div>
              <div class="text-sm text-slate-500">Photos</div>
            </div>
            <div class="text-center">
              <div class="text-2xl font-bold text-purple-600">-</div>
              <div class="text-sm text-slate-500">Projects</div>
            </div>
            <div class="text-center">
              <div class="text-2xl font-bold text-orange-600">Active</div>
              <div class="text-sm text-slate-500">Status</div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end