defmodule WebsiteWeb.WorkLive do
  use WebsiteWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:current_path, "/work")
      |> assign(:base_title, "Work")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-white via-green-50 to-emerald-50">
      <!-- Floating decorative elements -->
      <div class="absolute inset-0 overflow-hidden pointer-events-none">
        <div class="absolute top-20 left-16 w-24 h-24 bg-gradient-to-r from-emerald-300 to-teal-300 blob opacity-20 float-slow"></div>
        <div class="absolute bottom-32 right-20 w-16 h-16 bg-gradient-to-r from-green-300 to-lime-300 blob-2 opacity-25 float-medium"></div>
        <div class="absolute top-1/3 left-1/4 w-14 h-28 bg-gradient-to-b from-orange-200 to-amber-200 opacity-30 transform -rotate-12" style="border-radius: 70% 30% 40% 60% / 80% 20% 60% 40%;"></div>
      </div>

      <!-- Hero Section -->
      <section class="relative pt-20 pb-16">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="text-center mb-16">
            <div class="relative inline-block mb-2">
              <h1 class="text-4xl sm:text-5xl lg:text-6xl font-display font-bold text-slate-900 mb-8 pb-2">
                My <span class="bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent font-flower transform -rotate-1 inline-block pb-4">Journey</span>
              </h1>
              <span class="handwritten text-lg text-orange-500 absolute -top-2 -right-12 transform rotate-12">career path!</span>
            </div>
            <p class="text-xl text-slate-600 max-w-3xl mx-auto leading-relaxed">
              From student to professional developer - here's the path that shaped my career.
              <span class="font-mono bg-green-100 px-2 py-1 rounded text-emerald-700 ml-2">Let's dive in!</span>
            </p>
          </div>
        </div>
      </section>

      <!-- Main Content -->
      <section class="pb-20">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-16">
            <!-- Experience Timeline -->
            <div class="space-y-8">
              <div class="mb-8">
                <div class="flex items-start">
                  <div class="w-12 h-12 bg-gradient-to-r from-emerald-500 to-teal-500 rounded-full flex items-center justify-center mr-4 float-slow">
                    <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2H5a2 2 0 00-2 2z"/>
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V5a2 2 0 012-2h4a2 2 0 012 2v2"/>
                    </svg>
                  </div>
                  <div>
                    <h2 class="text-3xl font-display font-bold text-slate-900 mb-2">Professional Experience</h2>
                    <span class="handwritten text-orange-500 text-sm transform -rotate-1 inline-block">building & learning</span>
                    <p class="text-lg text-slate-600 mt-2">Building solutions and growing through challenges</p>
                  </div>
                </div>
              </div>

              <div class="relative">
                <!-- Timeline line -->
                <div class="absolute left-8 top-0 bottom-0 w-1 bg-gradient-to-b from-emerald-500 to-teal-500 rounded-full"></div>

                <div class="space-y-12">
                  <.timeline_card
                    date="April 2022 - Present"
                    workplace="Info~Tech Research Group"
                    role="Intermediate Software Developer"
                    points={[
                      "Developed various applications using Ruby on Rails, Javascript, and Python, primarily focused on HR related diagnostics.",
                      "Refactored and optimized data pipelines utilizing PySpark and AWS technologies, including Glue, Step Functions, Lambdas, and Athena.",
                      "Provided client support and managed incoming support requests.",
                      "Directed a team of engineers during an internal hackathon to prototype an AI-powered feature that was later approved for integration into the product roadmap.",
                      "Recognized as IT Person of the Month twice for outstanding contributions.",
                      "Earned Professional Scrum Master certification."
                    ]}
                  />
                  <.timeline_card
                    date="November 2020 - April 2022"
                    workplace="ShopDesk"
                    role="Full Stack Developer"
                    points={[
                      "Rebuilt a car dealership web application using Laravel and VueJS to streamline the sale of car accessories.",
                      "Independently handled the full-stack redevelopment process, including frontend, backend, and database integration.",
                      "Migrated the entire database from the legacy system to the new platform, ensuring a smooth transition with no data loss.",
                      "Improved user experience and optimized the application for scalability and performance."
                    ]}
                  />
                  <.timeline_card
                    date="2020"
                    workplace="University of Western Ontario"
                    role="Bachelor of Science in Computer Science"
                    points={[
                      "Graduated with a strong foundation in computer science fundamentals and software engineering principles."
                    ]}
                    is_education={true}
                  />
                </div>
              </div>
            </div>

            <!-- Tech Stack -->
            <div class="space-y-8">
              <div class="mb-8">
                <div class="flex items-start">
                  <div class="w-12 h-12 bg-gradient-to-r from-orange-500 to-amber-500 rounded-full flex items-center justify-center mr-4 float-medium">
                    <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"/>
                    </svg>
                  </div>
                  <div>
                    <h2 class="text-3xl font-display font-bold text-slate-900 mb-2">Tech Arsenal</h2>
                    <span class="handwritten text-emerald-500 text-sm transform rotate-1 inline-block">my daily tools</span>
                    <p class="text-lg text-slate-600 mt-2">Technologies and tools I work with daily</p>
                  </div>
                </div>
              </div>

              <div class="space-y-6">
                <!-- Languages -->
                <div class="card p-6">
                  <div class="flex items-center mb-4">
                    <div class="w-12 h-12 bg-gradient-to-r from-emerald-500 to-green-500 rounded-xl flex items-center justify-center mr-4">
                      <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"/>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 13h8M8 17h8M8 9h2"/>
                      </svg>
                    </div>
                    <h3 class="text-xl font-bold text-neutral-900">Languages</h3>
                  </div>
                  <div class="flex flex-wrap gap-3">
                    <%= for lang <- ["Ruby", "Python", "PHP", "JavaScript", "Elixir", "SQL"] do %>
                      <span class="px-3 py-1 bg-emerald-100 text-emerald-700 rounded-full text-sm font-medium">
                        <%= lang %>
                      </span>
                    <% end %>
                  </div>
                </div>

                <!-- Frameworks -->
                <div class="card p-6">
                  <div class="flex items-center mb-4">
                    <div class="w-12 h-12 bg-gradient-to-r from-teal-500 to-emerald-500 rounded-xl flex items-center justify-center mr-4">
                      <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
                      </svg>
                    </div>
                    <h3 class="text-xl font-bold text-neutral-900">Frameworks & Libraries</h3>
                  </div>
                  <div class="flex flex-wrap gap-3">
                    <%= for framework <- ["Ruby on Rails", "Phoenix", "VueJS", "Laravel", "LiveView", "TailwindCSS"] do %>
                      <span class="px-3 py-1 bg-teal-100 text-teal-700 rounded-full text-sm font-medium">
                        <%= framework %>
                      </span>
                    <% end %>
                  </div>
                </div>

                <!-- Cloud & DevOps -->
                <div class="card p-6">
                  <div class="flex items-center mb-4">
                    <div class="w-12 h-12 bg-gradient-to-r from-green-500 to-lime-500 rounded-xl flex items-center justify-center mr-4">
                      <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2m-2-4h.01M17 16h.01"/>
                      </svg>
                    </div>
                    <h3 class="text-xl font-bold text-neutral-900">Cloud & Infrastructure</h3>
                  </div>
                  <div class="flex flex-wrap gap-3">
                    <%= for tool <- ["AWS", "PySpark", "Terraform", "S3", "Glue", "Lambda", "Step Functions", "Athena"] do %>
                      <span class="px-3 py-1 bg-green-100 text-green-700 rounded-full text-sm font-medium">
                        <%= tool %>
                      </span>
                    <% end %>
                  </div>
                </div>

                <!-- Databases -->
                <div class="card p-6">
                  <div class="flex items-center mb-4">
                    <div class="w-12 h-12 bg-gradient-to-r from-emerald-500 to-teal-500 rounded-xl flex items-center justify-center mr-4">
                      <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4"/>
                      </svg>
                    </div>
                    <h3 class="text-xl font-bold text-neutral-900">Databases</h3>
                  </div>
                  <div class="flex flex-wrap gap-3">
                    <%= for db <- ["PostgreSQL", "MySQL", "Redis"] do %>
                      <span class="px-3 py-1 bg-emerald-100 text-emerald-700 rounded-full text-sm font-medium">
                        <%= db %>
                      </span>
                    <% end %>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
    """
  end

  attr :date, :string
  attr :workplace, :string
  attr :role, :string, default: nil
  attr :points, :list
  attr :is_education, :boolean, default: false

  def timeline_card(assigns) do
    ~H"""
    <div class="relative pl-20 pb-8">
      <!-- Timeline marker -->
      <div class="absolute left-6 w-4 h-4 bg-gradient-to-r from-emerald-600 to-teal-500 rounded-full shadow-lg"></div>

      <!-- Content card -->
      <div class="card p-6 ml-4">
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-4">
          <div>
            <h3 class="text-xl font-bold text-neutral-900 mb-1"><%= @workplace %></h3>
            <%= if @role do %>
              <p class="text-lg text-emerald-600 font-medium mb-2"><%= @role %></p>
            <% end %>
          </div>
          <span class="text-sm font-medium text-neutral-500 bg-neutral-100 px-3 py-1 rounded-full whitespace-nowrap">
            <%= @date %>
          </span>
        </div>

        <div class="space-y-3">
          <%= for point <- @points do %>
            <div class="flex items-start">
              <%= if @is_education do %>
                <svg class="w-5 h-5 text-orange-500 mt-0.5 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14zm-4 6v-7.5l4-2.222"/>
                </svg>
              <% else %>
                <svg class="w-5 h-5 text-emerald-500 mt-0.5 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
              <% end %>
              <p class="text-neutral-600 leading-relaxed"><%= point %></p>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
