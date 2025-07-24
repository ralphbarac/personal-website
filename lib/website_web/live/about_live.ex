defmodule WebsiteWeb.AboutLive do
  use WebsiteWeb, :live_view

  alias Website.Gallery
  alias Website.PhotoLayoutEngine

  def mount(_params, _session, socket) do
    categories = Gallery.get_categories_with_all()
    photos = Gallery.fetch_photos_by_category("All")
    layout_data = PhotoLayoutEngine.generate_layout(photos)
    
    socket =
      socket
      |> assign(:categories, categories)
      |> assign(:selected_category, "All")
      |> assign(:photos, photos)
      |> assign(:layout_data, layout_data)
      |> assign(:grid_classes, PhotoLayoutEngine.get_grid_classes())
      |> assign(:current_path, "/about")
      |> assign(:base_title, "About")

    {:ok, socket}
  end

  def handle_event("filter", %{"category" => category}, socket) do
    filtered_photos = Gallery.fetch_photos_by_category(category)
    layout_data = PhotoLayoutEngine.generate_layout(filtered_photos)

    {:noreply, assign(socket, 
      selected_category: category, 
      photos: filtered_photos,
      layout_data: layout_data
    )}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-white via-green-50 to-emerald-50">
      <!-- Floating decorative elements -->
      <div class="absolute inset-0 overflow-hidden pointer-events-none">
        <div class="absolute top-32 right-20 w-20 h-20 bg-gradient-to-r from-teal-300 to-emerald-300 blob opacity-20 float-slow"></div>
        <div class="absolute bottom-40 left-16 w-16 h-16 bg-gradient-to-r from-green-300 to-lime-300 blob-2 opacity-25 float-medium"></div>
        <div class="absolute top-1/2 right-1/4 w-12 h-24 bg-gradient-to-b from-orange-200 to-amber-200 opacity-30 transform rotate-45" style="border-radius: 50% 20% 80% 30% / 60% 70% 30% 40%;"></div>
      </div>

      <!-- Hero Section -->
      <section class="relative pt-24 pb-16">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="text-center">
            <div class="relative inline-block">
              <h1 class="text-4xl sm:text-5xl lg:text-6xl font-display font-bold text-slate-900">
                About <span class="bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent font-flower transform -rotate-1 inline-block">Me</span>
              </h1>
              <span class="handwritten text-lg text-orange-500 absolute -top-4 -right-8 transform rotate-12">the human behind the code</span>
            </div>
          </div>
        </div>
      </section>

      <!-- Main Content -->
      <section class="pb-20">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <!-- Row 1: Two columns -->
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-16 items-start mb-20">
            <!-- Column 1: My Story -->
            <div class="card p-8 bg-white">
              <div class="flex items-start mb-6">
                <div class="w-12 h-12 bg-gradient-to-r from-emerald-500 to-teal-500 rounded-full flex items-center justify-center mr-4 float-slow">
                  <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                  </svg>
                </div>
                <div>
                  <h2 class="text-2xl font-display font-bold text-slate-900 mb-2">My Story</h2>
                  <span class="handwritten text-orange-500 text-sm transform -rotate-2 inline-block">the professional journey</span>
                </div>
              </div>
              <div class="prose prose-lg max-w-none">
                <p class="text-slate-600 leading-relaxed mb-4">
                  I'm an Intermediate Software Developer currently working at <span class="font-semibold text-teal-600">Info~Tech Research Group</span>, where I help build and maintain full stack applications in the HR diagnostics space. We do most of our work with <span class="font-mono bg-emerald-100 px-2 py-1 rounded text-emerald-700">Ruby on Rails</span>, but there's lots of Javascript involved as well.
                </p>
                <p class="text-slate-600 leading-relaxed mb-4">
                  I've also been lucky enough to get a start in data engineering and data pipeline building and maintenance using <span class="font-mono bg-green-100 px-2 py-1 rounded text-green-700">PySpark</span> and various AWS technologies including Glue Jobs, Step Functions, Lambdas, and Athena.
                </p>
                <p class="text-slate-600 leading-relaxed">
                  Outside of work, I'm mostly dabbling with <span class="font-mono bg-teal-100 px-2 py-1 rounded text-teal-700">Elixir and Phoenix</span> <span class="handwritten text-orange-500">(like this site!)</span>. After years of Object Oriented Programming, using a purely functional language has been a breath of fresh air.
                </p>
              </div>
            </div>

            <!-- Column 2: Beyond Code -->
            <div class="card p-8 bg-white">
              <div class="flex items-start mb-6">
                <div class="w-12 h-12 bg-gradient-to-r from-orange-500 to-amber-500 rounded-full flex items-center justify-center mr-4 float-medium">
                  <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.828 14.828a4 4 0 01-5.656 0M9 10h1.01M15 10h1.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                  </svg>
                </div>
                <div>
                  <h2 class="text-2xl font-display font-bold text-slate-900 mb-2">Beyond Code</h2>
                  <span class="handwritten text-emerald-500 text-sm transform rotate-1 inline-block">the fun stuff!</span>
                </div>
              </div>
              <div class="prose prose-lg max-w-none">
                <p class="text-slate-600 leading-relaxed mb-4">
                  I like to think I'm pretty diverse and have a very whacky assortment of hobbies outside of programming. I run <span class="font-semibold text-orange-600">D&D games</span> for my friends (and sometimes at work), I love watching and playing hockey, and besides your nonna I <em>might</em> just be the best cook you know <span class="handwritten text-orange-500">(as long as you don't catch me experimenting!)</span>
                </p>
                <p class="text-slate-500 italic flex items-center">
                  <span class="mr-2">🏌️‍♂️</span>
                  Still trying to break 100 on the golf course though...
                </p>
              </div>
            </div>
          </div>

          <!-- Row 2: Full width photo gallery -->
          <div class="card p-8 bg-white">
            <div class="flex items-start mb-6">
              <div class="w-12 h-12 bg-gradient-to-r from-teal-500 to-green-500 rounded-full flex items-center justify-center mr-4 float-slow">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                </svg>
              </div>
              <div>
                <h2 class="text-2xl font-display font-bold text-slate-900 mb-2">Life in Pictures</h2>
                <span class="handwritten text-teal-500 text-sm transform rotate-2 inline-block">moments captured!</span>
              </div>
            </div>

            <!-- Category Filters -->
            <div class="flex flex-wrap gap-3 mb-8">
              <%= for category <- @categories do %>
                <button
                  phx-click="filter"
                  phx-value-category={category}
                  class={[
                    "px-4 py-2 text-sm font-semibold transition-all duration-300 transform hover:scale-105",
                    if(@selected_category == category,
                      do: "bg-gradient-to-r from-emerald-500 to-teal-500 text-white shadow-lg scale-105",
                      else: "bg-green-100 text-green-700 hover:bg-emerald-100 hover:text-emerald-700"
                    ),
                    "rounded-xl"
                  ]}
                  style={if @selected_category == category, do: "border-radius: var(--border-organic);", else: "border-radius: var(--border-quirky);"}
                >
                  <%= category %>
                </button>
              <% end %>
            </div>

            <!-- Photo Collage -->
            <div class={[@grid_classes, "transition-all duration-300 ease-in-out"]}>
              <%= for layout_item <- @layout_data do %>
                <%= smart_gallery_image(assigns, layout_item) %>
              <% end %>
            </div>
          </div>
        </div>
      </section>
    </div>
    """
  end

  def smart_gallery_image(assigns, layout_item) do
    assigns = assign(assigns, :layout_item, layout_item)
    ~H"""
    <div class={@layout_item.container_classes}>
      <div class="relative overflow-hidden bg-neutral-100 w-full h-full rounded-2xl shadow-md">
        <img
          src={@layout_item.photo.image_path}
          alt={@layout_item.photo.description}
          class={@layout_item.image_classes}
        />
        <!-- Overlay -->
        <div class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-all duration-300">
          <div class="absolute bottom-0 left-0 right-0 p-4">
            <p class="text-white text-sm font-medium leading-relaxed">
              <%= @layout_item.photo.description %>
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end

end
