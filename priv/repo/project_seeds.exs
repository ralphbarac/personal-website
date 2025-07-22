# Seeds specifically for projects
# Run with: mix run priv/repo/project_seeds.exs

alias Website.Repo
alias Website.Projects
alias Website.Projects.{Project, ProjectStatus, Technology}

# Create project statuses (only if they don't exist)
live_status = case Projects.get_project_status_by_slug("live") do
  nil -> 
    Repo.insert!(%ProjectStatus{
      name: "Live",
      slug: "live",
      description: "Project is live and publicly accessible"
    })
  existing -> existing
end

in_development_status = case Projects.get_project_status_by_slug("in-development") do
  nil ->
    Repo.insert!(%ProjectStatus{
      name: "In Development",
      slug: "in-development",
      description: "Project is currently being developed"
    })
  existing -> existing
end

completed_status = case Projects.get_project_status_by_slug("completed") do
  nil ->
    Repo.insert!(%ProjectStatus{
      name: "Completed",
      slug: "completed",
      description: "Project has been completed"
    })
  existing -> existing
end

# Create technologies (only if they don't exist)
technologies_data = [
  {"Elixir", "elixir"},
  {"Phoenix", "phoenix"},
  {"LiveView", "liveview"},
  {"PostgreSQL", "postgresql"},
  {"TailwindCSS", "tailwindcss"},
  {"PHP", "php"},
  {"Laravel", "laravel"},
  {"VueJS", "vuejs"},
  {"MySQL", "mysql"},
  {"Bootstrap", "bootstrap"}
]

technologies = Enum.map(technologies_data, fn {name, slug} ->
  case Projects.get_technology_by_slug(slug) do
    nil -> Repo.insert!(%Technology{name: name, slug: slug})
    existing -> existing
  end
end)

[elixir, phoenix, liveview, postgresql, tailwindcss, php, laravel, vuejs, mysql, bootstrap] = technologies

# Create projects (only if they don't exist)
dnd_project = case Repo.get_by(Project, title: "Phoenix D&D Platform") do
  nil ->
    {:ok, project} = Projects.create_project(%{
      title: "Phoenix D&D Platform",
      description: "An online tabletop gaming platform built with Phoenix LiveView for managing D&D campaigns, character sheets, and virtual dice rolling.",
      project_status_id: in_development_status.id,
      featured: true
    })
    project
  existing -> existing
end

website_project = case Repo.get_by(Project, title: "Personal Website") do
  nil ->
    {:ok, project} = Projects.create_project(%{
      title: "Personal Website",
      description: "This very website! A modern, responsive personal portfolio and blog built with Phoenix LiveView and TailwindCSS.",
      github_url: "https://github.com/ralphbarac/website",
      project_status_id: live_status.id,
      featured: true
    })
    project
  existing -> existing
end

shopdesk_project = case Repo.get_by(Project, title: "ShopDesk Platform Rebuild") do
  nil ->
    {:ok, project} = Projects.create_project(%{
      title: "ShopDesk Platform Rebuild",
      description: "Complete rebuild of a car dealership web application using Laravel and VueJS, including database migration and performance optimization.",
      project_status_id: completed_status.id,
      featured: false
    })
    project
  existing -> existing
end

# Associate technologies with projects (only if not already associated)
Projects.associate_technologies(dnd_project, [elixir, phoenix, liveview, postgresql, tailwindcss])
Projects.associate_technologies(website_project, [elixir, phoenix, liveview, postgresql, tailwindcss])
Projects.associate_technologies(shopdesk_project, [php, laravel, vuejs, mysql, bootstrap])

IO.puts("Projects seeded successfully!")