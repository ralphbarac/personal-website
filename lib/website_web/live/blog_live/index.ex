defmodule WebsiteWeb.BlogLive.Index do
  alias Website.Blog.{Posts, Categories}
  use WebsiteWeb, :live_view

  alias Website.Blog.Post

  def mount(_params, _session, socket) do
    posts = Posts.list_published_posts()
    categories = Categories.list_categories()

    socket =
      socket
      |> stream(:posts, posts)
      |> assign(:current_path, "/blog")
      |> assign(:base_title, "Blog")
      |> assign(:categories, categories)
      |> assign(:selected_category_id, nil)

    {:ok, socket}
  end

  def handle_event("filter_category", %{"category_id" => ""}, socket) do
    # Show all posts
    posts = Posts.list_published_posts()
    
    socket =
      socket
      |> stream(:posts, posts, reset: true)
      |> assign(:selected_category_id, nil)
    
    {:noreply, socket}
  end

  def handle_event("filter_category", %{"category_id" => category_id}, socket) do
    category_id = String.to_integer(category_id)
    posts = Posts.list_published_posts_by_category(category_id)
    
    socket =
      socket
      |> stream(:posts, posts, reset: true)
      |> assign(:selected_category_id, category_id)
    
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-white via-green-50 to-emerald-50">
      <!-- Floating decorative elements -->
      <div class="absolute inset-0 overflow-hidden pointer-events-none">
        <div class="absolute top-24 right-12 w-20 h-20 bg-gradient-to-r from-emerald-300 to-teal-300 blob opacity-20 float-slow"></div>
        <div class="absolute bottom-40 left-20 w-16 h-16 bg-gradient-to-r from-green-300 to-lime-300 blob-2 opacity-25 float-medium"></div>
        <div class="absolute top-1/2 right-1/3 w-12 h-24 bg-gradient-to-b from-orange-200 to-amber-200 opacity-30 transform rotate-12" style="border-radius: 60% 40% 80% 20% / 30% 70% 30% 70%;"></div>
      </div>

      <!-- Hero Section -->
      <section class="relative pt-20 pb-16">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="text-center mb-16">
            <div class="relative inline-block mb-2">
              <h1 class="text-4xl sm:text-5xl lg:text-6xl font-display font-bold text-slate-900 mb-8 pb-2">
                <span class="bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent font-flower transform -rotate-1 inline-block pb-4 px-4">Blog</span>
              </h1>
              <span class="handwritten text-lg text-orange-500 absolute -top-4 -right-8 transform rotate-12">brain dumps!</span>
            </div>
            <p class="text-xl text-slate-600 max-w-3xl mx-auto leading-relaxed">
              Thoughts, tutorials, and insights about software development, technology, and continuous learning.
              <span class="font-mono bg-green-100 px-2 py-1 rounded text-emerald-700 block mt-2">Fresh ideas served...occasionally!</span>
            </p>
          </div>
        </div>
      </section>

      <!-- Category Filter Pills -->
      <section class="pb-8">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex justify-center">
            <div class="flex flex-wrap justify-center gap-3 max-w-4xl">
              <!-- All Posts Filter -->
              <button 
                phx-click="filter_category" 
                phx-value-category_id=""
                class={[
                  "inline-flex items-center px-4 py-2 rounded-full text-sm font-semibold transition-all duration-300 hover:scale-105 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2",
                  if(@selected_category_id == nil,
                    do: "bg-gradient-to-r from-emerald-500 to-teal-500 text-white shadow-lg transform scale-105",
                    else: "bg-gradient-to-r from-emerald-100 to-green-100 text-emerald-700 hover:from-emerald-200 hover:to-green-200"
                  )
                ]}
              >
                All Posts
              </button>
              
              <!-- Category Filters -->
              <button 
                :for={category <- @categories}
                phx-click="filter_category" 
                phx-value-category_id={category.id}
                class={[
                  "inline-flex items-center px-4 py-2 rounded-full text-sm font-semibold transition-all duration-300 hover:scale-105 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2",
                  if(@selected_category_id == category.id,
                    do: "bg-gradient-to-r from-emerald-500 to-teal-500 text-white shadow-lg transform scale-105",
                    else: "bg-gradient-to-r from-emerald-100 to-green-100 text-emerald-700 hover:from-emerald-200 hover:to-green-200"
                  )
                ]}
              >
                <%= category.name %>
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- Blog Posts Grid -->
      <section class="pb-20">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 transition-all duration-500" id="posts" phx-update="stream">
            <.blog_card :for={{dom_id, post} <- @streams.posts} post={post} id={dom_id}/>
          </div>
        </div>
      </section>
    </div>
    """
  end

  attr :post, Post, required: true
  attr :id, :string, required: :true

  def blog_card(assigns) do
    ~H"""
    <article class="card group cursor-pointer overflow-hidden h-full bg-white hover:shadow-xl transition-all duration-300 hover:scale-105">
      <.link navigate={~p"/blog/posts/#{@post}"} id={@id} class="block h-full">
        <!-- Featured Image -->
        <div class="relative h-48 overflow-hidden bg-green-50">
          <img
            src={@post.image_path}
            alt={@post.title}
            class="w-full h-full object-cover transition-all duration-500 group-hover:scale-110"
          />
          <div class="absolute inset-0 bg-gradient-to-t from-black/30 via-transparent to-transparent"></div>
        </div>

        <!-- Content -->
        <div class="p-6 flex flex-col flex-1">
          <!-- Category Badge -->
          <div class="mb-4">
            <span class="inline-flex items-center px-3 py-1 text-xs font-semibold bg-gradient-to-r from-emerald-100 to-green-100 text-emerald-700 rounded-full">
              <%= @post.category.name %>
            </span>
          </div>

          <!-- Title -->
          <h3 class="text-xl font-display font-bold text-slate-900 mb-3 line-clamp-2 group-hover:text-emerald-600 transition-colors duration-300">
            <%= @post.title %>
          </h3>

          <!-- Description -->
          <p class="text-slate-600 leading-relaxed mb-6 line-clamp-3 flex-grow">
            <%= @post.description %>
          </p>

          <!-- Meta Information -->
          <div class="flex items-center justify-between pt-4 border-t border-green-100">
            <div class="flex items-center text-sm text-slate-500">
              <svg class="w-4 h-4 mr-2 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
              </svg>
              <time datetime={@post.inserted_at}>
                <%= Calendar.strftime(@post.inserted_at, "%B %d, %Y") %>
              </time>
            </div>

            <div class="flex items-center text-sm text-slate-500">
              <svg class="w-4 h-4 mr-2 text-teal-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
              <span><%= Post.format_read_time(@post) %></span>
            </div>
          </div>

          <!-- Read More Arrow -->
          <div class="flex items-center mt-4 text-emerald-600 group-hover:text-emerald-700 transition-colors duration-300">
            <span class="text-sm font-medium mr-2">Read more</span>
            <svg class="w-4 h-4 transition-transform group-hover:translate-x-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
            </svg>
          </div>
        </div>
      </.link>
    </article>
    """
  end
end
