# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Website.Repo.insert!(%Website.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Website.Repo
alias Website.Blog.{Category, Post}
alias Website.Photo
alias Website.Projects
alias Website.Projects.{Project, ProjectStatus, Technology}
alias Website.Accounts

Repo.insert!(%Category{name: "dev", slug: "dev", description: "my musings on software development and technology"})
Repo.insert!(%Category{name: "games", slug: "games", description: "my musings on games"})

posts = [
  %{
    title: "My First Blog Post",
    body: "This is the body of the blog post.",
    description: "This is a test description for a post",
    slug: "my-first-blog-post",
    image_path: "/images/blog/escaping_tutorials.jpg",
    category_id: 1
  },
  %{
    title: "test",
    body: "testestestestsetsest.",
    description: "This is a test description for a post",
    slug: "my-second-blog-post",
    image_path: "/images/blog/escaping_tutorials.jpg",
    category_id: 1
  },
  %{
    title: "test",
    body: "testestestestsetsest",
    description: "This is a test description for a post",
    slug: "my-third-blog-post",
    image_path: "/images/blog/escaping_tutorials.jpg",
    category_id: 2
  },
  %{
    title: "test",
    body: "testestestestsetsest",
    description: "This is a test description for a post",
    slug: "my-fourth-blog-post",
    image_path: "/images/blog/escaping_tutorials.jpg",
    category_id: 2
  },
  %{
    title: "test",
    body: "testestestestsetsest",
    description: "This is a test description for a post",
    slug: "my-fifth-blog-post",
    image_path: "/images/blog/escaping_tutorials.jpg",
    category_id: 1
  }
]

for post_attrs <- posts do
  changeset = Post.changeset(%Post{}, post_attrs)

  case Repo.insert(changeset) do
    {:ok, _post} -> IO.puts("Post created.")
    {:error, changeset} -> IO.inspect(changeset.errors, label: "Failed to create post.")
  end
end

photos = [
  %{description: "The coolest thing I've ever done was officiate my friends wedding.", category: "Me", image_path: "/images/about/wedding.jpg"},
  %{description: "Mat's my best bud.", category: "Me", image_path: "/images/about/me_with_mat.jpg"},
  %{description: "I'm an uncle now!", category: "Me", image_path: "/images/about/me_with_rosie.jpg"},
  %{description: "Speech at my sister's wedding.", category: "Me", image_path: "/images/about/me_with_eileen_wedding.jpg"},
  %{description: "I used to be cool.", category: "Me", image_path: "/images/about/me_cool.jpg"},
  %{description: "My girlfriend and I giving free labour to apple orchards.", category: "Me", image_path: "/images/about/me_with_annie.jpg"},
  %{description: "Abu Dhabi was a little too sunny to keep my eyes open for photos.", category: "Me", image_path: "/images/about/me_in_abu_dhabi.jpeg"},
  %{description: "Moments before they threw me headfirst into the pool.", category: "Me", image_path: "/images/about/me_with_friends.jpg"},
  %{description: "I thought we were going to a baptism.", category: "Me", image_path: "/images/about/me_surprised.jpeg"},
  %{description: "I didn't know what to do with all the leftover polenta.", category: "Cooking", image_path: "/images/about/beef_and_polenta.jpg"},
  %{description: "Pretty spot on Beef Wellington.", category: "Cooking", image_path: "/images/about/beef_wellington.jpg"},
  %{description: "There's a million ways to make chicken and rice but this one is the best way.", category: "Cooking", image_path: "/images/about/chicken_and_rice.jpg"},
  %{description: "General Tso's Chicken.", category: "Cooking", image_path: "/images/about/general_tsos.jpg"},
  %{description: "Japanese Curry.", category: "Cooking", image_path: "/images/about/japanese_curry.jpg"},
  %{description: "The best leek and potato soup recipe courtesy of Chef Jack Ovens.", category: "Cooking", image_path: "/images/about/leek_and_potato_soup.jpg"},
  %{description: "A summer pasta recipe I found on Instagram.", category: "Cooking", image_path: "/images/about/summer_pasta.jpg"},
  %{description: "Thanksgiving Dinner 2023.", category: "Cooking", image_path: "/images/about/thanksgiving_dinner.jpg"}
]

for photo <- photos do
  %Photo{}
  |> Photo.changeset(photo)
  |> Repo.insert!()
end

# Project-related seeds

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
