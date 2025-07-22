defmodule WebsiteWeb.ProjectsLive do
  use WebsiteWeb, :live_view

  alias Website.Projects

  def mount(_params, _session, socket) do
    projects = Projects.list_projects()

    socket =
      socket
      |> assign(:projects, projects)
      |> assign(:current_path, "/projects")
      |> assign(:base_title, "Projects")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-white via-green-50 to-emerald-50">
      <!-- Floating decorative elements -->
      <div class="absolute inset-0 overflow-hidden pointer-events-none">
        <div class="absolute top-24 left-20 w-20 h-20 bg-gradient-to-r from-emerald-300 to-teal-300 blob opacity-20 float-slow"></div>
        <div class="absolute bottom-40 right-16 w-16 h-16 bg-gradient-to-r from-green-300 to-lime-300 blob-2 opacity-25 float-medium"></div>
        <div class="absolute top-1/3 left-1/2 w-14 h-28 bg-gradient-to-b from-orange-200 to-amber-200 opacity-30 transform rotate-12" style="border-radius: 60% 40% 70% 30% / 80% 20% 60% 40%;"></div>
      </div>

      <!-- Hero Section -->
      <section class="relative pt-20 pb-2">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="text-center mb-16">
            <div class="relative inline-block mb-2">
              <h1 class="text-4xl sm:text-5xl lg:text-6xl font-display font-bold text-slate-900 mb-2">
                <span class="bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent font-flower transform -rotate-1 inline-block pb-4">Projects</span>
              </h1>
              <span class="handwritten text-lg text-orange-500 absolute -top-4 -right-12 transform rotate-12">things I built!</span>
            </div>
            <p class="text-xl text-slate-600 max-w-3xl mx-auto leading-relaxed">
              A collection of projects I've completed or am currently working on.
              <span class="font-mono bg-green-100 px-2 py-1 rounded text-emerald-700 block mt-2">Code, creativity & caffeine!</span>
            </p>
          </div>
        </div>
      </section>

      <!-- Projects Grid -->
      <section class="pb-20">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <!-- Featured Projects -->
          <div class="mb-16">
            <div class="flex items-center mb-8">
              <div class="w-12 h-12 bg-gradient-to-r from-emerald-500 to-teal-500 rounded-full flex items-center justify-center mr-4 float-slow">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z"/>
                </svg>
              </div>
              <div>
                <h2 class="text-3xl font-display font-bold text-slate-900">Featured Projects</h2>
                <span class="handwritten text-orange-500 text-sm transform -rotate-1 inline-block">the main attractions!</span>
              </div>
            </div>
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
              <.project_card :for={project <- Enum.filter(@projects, &(&1.featured))} project={project} featured={true}/>
            </div>
          </div>

          <!-- Other Projects -->
          <%= if Enum.any?(@projects, &(!&1.featured)) do %>
            <div>
              <div class="flex items-center mb-8">
                <div class="w-12 h-12 bg-gradient-to-r from-teal-500 to-green-500 rounded-full flex items-center justify-center mr-4 float-medium">
                  <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
                  </svg>
                </div>
                <div>
                  <h2 class="text-3xl font-display font-bold text-slate-900">Other Projects</h2>
                  <span class="handwritten text-emerald-500 text-sm transform rotate-1 inline-block">more fun stuff!</span>
                </div>
              </div>
              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <.project_card :for={project <- Enum.filter(@projects, &(!&1.featured))} project={project} featured={false}/>
              </div>
            </div>
          <% end %>
        </div>
      </section>
    </div>
    """
  end

  attr :project, :map, required: true
  attr :featured, :boolean, default: false

  def project_card(assigns) do
    ~H"""
    <div class="card group cursor-pointer overflow-hidden h-full bg-white hover:shadow-xl transition-all duration-300 hover:scale-105">
      <div class="p-6">
        <!-- Status Badge -->
        <div class="flex items-center justify-between mb-4">
          <span class={[
            "inline-flex items-center px-3 py-2 text-xs font-semibold rounded-full transition-all duration-200",
            case @project.project_status.name do
              "Live" -> "bg-gradient-to-r from-emerald-100 to-green-100 text-emerald-700"
              "In Development" -> "bg-gradient-to-r from-orange-100 to-amber-100 text-orange-700"
              "Completed" -> "bg-gradient-to-r from-teal-100 to-emerald-100 text-teal-700"
              _ -> "bg-neutral-100 text-neutral-700"
            end
          ]}>
            <div class={[
              "w-2 h-2 rounded-full mr-2 animate-pulse",
              case @project.project_status.name do
                "Live" -> "bg-emerald-500"
                "In Development" -> "bg-orange-500"
                "Completed" -> "bg-teal-500"
                _ -> "bg-neutral-500"
              end
            ]}></div>
            <%= @project.project_status.name %>
          </span>
        </div>

        <!-- Title -->
        <h3 class={[
          "font-display font-bold text-slate-900 mb-3 group-hover:text-emerald-600 transition-colors duration-300",
          if(@featured, do: "text-2xl", else: "text-xl")
        ]}>
          <%= @project.title %>
        </h3>

        <!-- Description -->
        <p class={[
          "text-slate-600 leading-relaxed mb-6",
          if(@featured, do: "text-lg", else: "text-base")
        ]}>
          <%= @project.description %>
        </p>

        <!-- Technologies -->
        <div class="mb-6">
          <div class="flex flex-wrap gap-2">
            <%= for tech <- @project.technologies do %>
              <span class="px-3 py-1 bg-gradient-to-r from-green-100 to-emerald-100 text-emerald-700 rounded-full text-xs font-medium font-mono hover:scale-105 transition-all duration-200">
                <%= tech.name %>
              </span>
            <% end %>
          </div>
        </div>

        <!-- Links -->
        <div class="flex items-center space-x-6 pt-4 border-t border-green-100">
          <%= if @project.github_url do %>
            <a
              href={@project.github_url}
              target="_blank"
              rel="noopener noreferrer"
              class="inline-flex items-center text-slate-600 hover:text-slate-900 transition-all duration-200 group/link"
            >
              <svg class="w-5 h-5 mr-2 group-hover/link:scale-110 transition-transform" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
              </svg>
              <span class="text-sm font-medium">View Code</span>
            </a>
          <% end %>

          <%= if @project.live_url do %>
            <a
              href={@project.live_url}
              target="_blank"
              rel="noopener noreferrer"
              class="inline-flex items-center text-emerald-600 hover:text-emerald-700 transition-all duration-200 group/link font-medium"
            >
              <svg class="w-5 h-5 mr-2 group-hover/link:scale-110 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
              </svg>
              <span class="text-sm">Live Demo</span>
            </a>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
