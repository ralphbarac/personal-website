defmodule WebsiteWeb.SplashLive do
  use WebsiteWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :current_path, "/")}
  end

  def render(assigns) do
    ~H"""
    <div class="relative overflow-hidden bg-gradient-to-br from-white via-green-50 to-emerald-50 min-h-screen">
      <!-- Floating decorative elements -->
      <div class="absolute inset-0 overflow-hidden pointer-events-none">
        <!-- Floating blobs -->
        <div class="absolute top-20 left-10 w-32 h-32 bg-gradient-to-r from-emerald-400 to-green-400 blob opacity-20 float-slow"></div>
        <div class="absolute top-40 right-20 w-24 h-24 bg-gradient-to-r from-teal-400 to-emerald-400 blob-2 opacity-25 float-medium"></div>
        <div class="absolute bottom-32 left-1/4 w-20 h-20 bg-gradient-to-r from-lime-400 to-green-400 blob opacity-30 float-slow"></div>

        <!-- Organic shapes -->
        <div class="absolute top-1/4 right-10 w-16 h-40 bg-gradient-to-b from-orange-200 to-amber-200 opacity-40 transform rotate-12" style="border-radius: 60% 40% 30% 70% / 60% 30% 70% 40%;"></div>
        <div class="absolute bottom-20 right-1/3 w-28 h-28 bg-gradient-to-br from-emerald-200 to-teal-300 opacity-35 transform -rotate-6" style="border-radius: 73% 27% 35% 65% / 28% 67% 33% 72%;"></div>
      </div>

      <!-- Main content -->
      <div class="relative z-10 min-h-screen flex items-center justify-center px-4 sm:px-6 lg:px-8">
        <div class="max-w-5xl mx-auto text-center">
          <!-- Playful introduction -->
          <div class="space-y-8">
            <!-- Handwritten greeting -->
            <div class="relative mb-8">
              <span class="handwritten text-2xl absolute -top-8 -left-4 transform -rotate-12">Hey there! 👋</span>
            </div>

            <!-- Main heading with personality -->
            <div class="space-y-6">
              <h1 class="text-4xl sm:text-5xl lg:text-6xl xl:text-7xl font-display font-bold text-slate-900 leading-tight">
                <span class="inline-block">I'm</span>
                <span class="inline-block bg-gradient-to-r from-emerald-600 via-green-600 to-teal-600 bg-clip-text text-transparent transform -rotate-1">
                  Ralph Barac
                </span>
                <br>
                <span class="inline-block text-3xl sm:text-4xl lg:text-5xl font-medium text-slate-700 mt-2">
                  and I <span class="underline-squiggly">love</span> building things
                </span>
              </h1>
            </div>

            <!-- Personality-rich description -->
            <div class="max-w-3xl mx-auto space-y-4">
              <p class="text-lg sm:text-xl text-slate-600 leading-relaxed">
                I'm a <span class="font-mono bg-green-100 px-2 py-1 rounded text-emerald-700">software developer</span> at
                <span class="font-semibold text-teal-600">Info~Tech Research Group</span>,
                where I craft elegant solutions and occasionally break things
                <span class="handwritten text-orange-500">(but fix them too!)</span>
              </p>

              <p class="text-lg text-slate-600 leading-relaxed">
                When I'm not coding, you'll find me running D&D campaigns,
                experimenting in the kitchen, or trying to break 100 on the golf course
                <span class="text-sm text-slate-500">(still working on that last one 😅)</span>
              </p>
            </div>

            <!-- Creative CTA section -->
            <div class="space-y-6 pt-8">
              <div class="flex flex-col sm:flex-row gap-6 justify-center items-center">
                <a href="/about" class="btn-primary group relative">
                  <span>Get to know me</span>
                  <svg class="w-5 h-5 ml-3 transition-transform group-hover:translate-x-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
                  </svg>
                </a>

                <a href="/blog" class="btn-secondary group">
                  <span>Read my brain dumps</span>
                  <svg class="w-5 h-5 ml-3 transition-transform group-hover:scale-110" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"/>
                  </svg>
                </a>
              </div>

              <!-- Quirky navigation hint -->
              <div class="text-center">
                <p class="text-sm text-slate-500 font-mono">
                  <span class="handwritten text-base text-orange-500 transform rotate-3 inline-block mr-2">psst:</span>
                  check out my
                  <a href="/work" class="text-emerald-600 hover:text-emerald-700 underline decoration-wavy decoration-green-400">work</a>
                  or browse my
                  <a href="/projects" class="text-teal-600 hover:text-teal-700 underline decoration-wavy decoration-emerald-400">projects</a>
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end


end
