defmodule WebsiteWeb.BlogLive.Show do
  use WebsiteWeb, :live_view
  
  alias Website.Blog

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:current_path, "/blog")
      |> assign(:base_title, "Blog")

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    # Try to get by slug first, then by ID for backwards compatibility
    post = 
      try do
        Blog.get_published_post_by_slug!(id)
      rescue
        Ecto.NoResultsError ->
          # If slug lookup fails, try by ID (but still ensure it's published)
          post = Blog.get_post!(id)
          if post.status == :published do
            post
          else
            raise Ecto.NoResultsError, queryable: Website.Blog.Post
          end
      end

    socket =
      socket
      |> assign(:post, post)
      |> assign(:base_title, post.title)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <article class="min-h-screen bg-gradient-to-br from-white via-green-50 to-emerald-50">
      <!-- Floating decorative elements -->
      <div class="absolute inset-0 overflow-hidden pointer-events-none">
        <div class="absolute top-32 left-16 w-20 h-20 bg-gradient-to-r from-teal-300 to-emerald-300 blob opacity-20 float-slow"></div>
        <div class="absolute bottom-40 right-12 w-16 h-16 bg-gradient-to-r from-green-300 to-lime-300 blob-2 opacity-25 float-medium"></div>
        <div class="absolute top-1/2 left-1/4 w-12 h-24 bg-gradient-to-b from-orange-200 to-amber-200 opacity-30 transform rotate-12" style="border-radius: 60% 40% 70% 30% / 80% 20% 60% 40%;"></div>
      </div>

      <!-- Hero Section -->
      <section class="pt-20 pb-16 relative">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <!-- Back Button -->
          <div class="mb-8">
            <.link navigate={~p"/blog"} class="inline-flex items-center text-slate-600 hover:text-emerald-600 transition-all duration-300 group font-medium">
              <svg class="w-5 h-5 mr-2 transition-transform group-hover:-translate-x-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
              </svg>
              Back to Blog
            </.link>
          </div>

          <!-- Article Header -->
          <div class="text-center mb-12">
            <!-- Category Badge -->
            <div class="mb-6">
              <span class="inline-flex items-center px-4 py-2 text-sm font-semibold bg-gradient-to-r from-emerald-100 to-green-100 text-emerald-700 rounded-full">
                <div class="w-2 h-2 bg-emerald-500 rounded-full mr-2"></div>
                <%= @post.category.name %>
              </span>
            </div>

            <!-- Title -->
            <div class="relative inline-block mb-6">
              <h1 class="text-3xl sm:text-4xl lg:text-5xl font-display font-bold text-slate-900 leading-tight">
                <span class="bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent">
                  <%= @post.title %>
                </span>
              </h1>
            </div>

            <!-- Description -->
            <p class="text-xl text-slate-600 mb-8 leading-relaxed max-w-3xl mx-auto">
              <%= @post.description %>
            </p>

            <!-- Meta Information -->
            <div class="flex flex-col sm:flex-row items-center justify-center space-y-2 sm:space-y-0 sm:space-x-6 text-slate-500">
              <div class="flex items-center">
                <div class="w-8 h-8 bg-gradient-to-r from-emerald-500 to-teal-500 rounded-full flex items-center justify-center mr-2">
                  <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                  </svg>
                </div>
                <time datetime={@post.inserted_at} class="font-medium">
                  <%= Calendar.strftime(@post.inserted_at, "%B %d, %Y") %>
                </time>
              </div>

              <div class="hidden sm:block text-green-300">•</div>

              <div class="flex items-center">
                <div class="w-8 h-8 bg-gradient-to-r from-orange-500 to-amber-500 rounded-full flex items-center justify-center mr-2">
                  <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                  </svg>
                </div>
                <span class="font-medium"><%= @post.read_time %> min read</span>
              </div>
            </div>
          </div>

          <%!-- <!-- Featured Image -->
          <%= if @post.image_path do %>
            <div class="mb-16">
              <div class="relative overflow-hidden card-quirky shadow-2xl">
                <img
                  src={@post.image_path}
                  alt={@post.title}
                  class="w-full h-64 sm:h-80 lg:h-96 object-cover"
                />
                <div class="absolute inset-0 bg-gradient-to-t from-black/20 via-transparent to-transparent"></div>
              </div>
            </div>
          <% end %> --%>
        </div>
      </section>

      <!-- Article Content -->
      <section class="pb-20">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <.article_content content={@post.body} />
        </div>
      </section>


      <!-- Back to Blog CTA -->
      <section class="pb-20">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <div class="mb-4">
            <span class="handwritten text-orange-500 text-lg transform -rotate-1 inline-block">more brain dumps await!</span>
          </div>
          <.link navigate={~p"/blog"} class="inline-flex items-center px-8 py-4 bg-gradient-to-r from-emerald-500 to-teal-500 text-white font-semibold rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105 group">
            <svg class="w-5 h-5 mr-2 transition-transform group-hover:-translate-x-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
            </svg>
            Read More Articles
          </.link>
        </div>
      </section>
    </article>
    """
  end

  attr :content, :string, required: true

  def article_content(assigns) do
    ~H"""
    <article
      class="bg-white px-8 py-12 sm:px-12 lg:px-16 lg:py-16 border border-slate-200 shadow-sm"
      role="main"
      aria-label="Article content"
    >
      <div class="prose prose-xl prose-slate max-w-none
                  prose-headings:text-slate-900 prose-headings:font-bold prose-headings:leading-tight prose-headings:mb-6 prose-headings:mt-10
                  prose-h1:text-3xl prose-h1:mt-0 prose-h1:mb-8
                  prose-h2:text-2xl prose-h2:border-b prose-h2:border-slate-200 prose-h2:pb-2
                  prose-h3:text-xl
                  prose-p:text-slate-700 prose-p:leading-relaxed prose-p:mb-6 prose-p:text-lg
                  prose-a:text-blue-600 prose-a:underline prose-a:decoration-2 prose-a:underline-offset-2 focus:prose-a:outline-2 focus:prose-a:outline-blue-600 focus:prose-a:outline-offset-2
                  prose-strong:text-slate-900 prose-strong:font-semibold
                  prose-em:text-slate-700 prose-em:italic
                  prose-code:text-slate-900 prose-code:bg-slate-100 prose-code:px-2 prose-code:py-1 prose-code:rounded prose-code:text-base prose-code:font-mono prose-code:font-medium
                  prose-pre:bg-slate-900 prose-pre:text-slate-100 prose-pre:p-6 prose-pre:rounded-lg prose-pre:overflow-x-auto prose-pre:text-sm
                  prose-blockquote:border-l-4 prose-blockquote:border-blue-500 prose-blockquote:bg-blue-50 prose-blockquote:px-6 prose-blockquote:py-4 prose-blockquote:italic prose-blockquote:text-slate-700 prose-blockquote:my-6
                  prose-ul:my-6 prose-ul:space-y-2 prose-ul:list-disc prose-ul:pl-6
                  prose-ol:my-6 prose-ol:space-y-2 prose-ol:list-decimal prose-ol:pl-6
                  prose-li:text-slate-700 prose-li:leading-relaxed prose-li:text-lg
                  prose-hr:border-slate-300 prose-hr:my-10
                  prose-table:border-collapse prose-table:border prose-table:border-slate-300
                  prose-th:border prose-th:border-slate-300 prose-th:bg-slate-50 prose-th:px-4 prose-th:py-2 prose-th:text-left prose-th:font-semibold
                  prose-td:border prose-td:border-slate-300 prose-td:px-4 prose-td:py-2
                  prose-img:rounded-lg prose-img:shadow-md prose-img:mx-auto"
      >
        <%= raw(@content) %>
      </div>
    </article>
    """
  end
end
