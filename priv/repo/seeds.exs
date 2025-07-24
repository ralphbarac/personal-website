# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# This seeds file is idempotent - it's safe to run multiple times.
# It checks for existing records before inserting to avoid duplicates.
#
# For development, you have two options:
# 1. Run seeds: `mix run priv/repo/seeds.exs` (safe, adds missing data)
# 2. Reset DB: `mix ecto.reset` (drops DB, recreates, runs migrations + seeds)
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Website.Repo.insert!(%Website.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query

alias Website.Repo
alias Website.Blog.{Category, Post}
alias Website.{Photo, PhotoCategory}
alias Website.Projects
alias Website.Projects.{Project, ProjectStatus, Technology}
alias Website.Accounts

# Create admin user if it doesn't exist
case Accounts.get_user_by_email("admin@localhost") do
  nil ->
    case Accounts.register_user(%{
      email: "admin@localhost",
      password: "admin123456789",
      password_confirmation: "admin123456789"
    }) do
      {:ok, _user} -> IO.puts("Admin user created successfully!")
      {:error, changeset} -> IO.inspect(changeset.errors, label: "Failed to create admin user")
    end
  _user -> IO.puts("Admin user already exists")
end

# Create blog categories (only if they don't exist)
dev_category = case Category |> where([c], c.slug == "dev") |> limit(1) |> Repo.one() do
  nil -> 
    Repo.insert!(%Category{name: "dev", slug: "dev", description: "my musings on software development and technology"})
  existing -> existing
end

games_category = case Category |> where([c], c.slug == "games") |> limit(1) |> Repo.one() do
  nil -> 
    Repo.insert!(%Category{name: "games", slug: "games", description: "my musings on games"})
  existing -> existing
end

posts = [
  %{
    title: "My First Blog Post",
    body: "This is the body of the blog post.",
    description: "This is a test description for a post",
    slug: "my-first-blog-post",
    image_path: "/images/blog/escaping_tutorials.jpg",
    category_id: dev_category.id,
    status: "published"
  },
  %{
    title: "test",
    body: "testestestestsetsest.",
    description: "This is a test description for a post",
    slug: "my-second-blog-post",
    image_path: "/images/blog/escaping_tutorials.jpg",
    category_id: dev_category.id,
    status: "published"
  },
  %{
    title: "test",
    body: "testestestestsetsest",
    description: "This is a test description for a post",
    slug: "my-third-blog-post",
    image_path: "/images/blog/escaping_tutorials.jpg",
    category_id: games_category.id,
    status: "published"
  },
  %{
    title: "test",
    body: "testestestestsetsest",
    description: "This is a test description for a post",
    slug: "my-fourth-blog-post",
    image_path: "/images/blog/escaping_tutorials.jpg",
    category_id: games_category.id,
    status: "draft"
  },
  %{
    title: "test",
    body: "testestestestsetsest",
    description: "This is a test description for a post",
    slug: "my-fifth-blog-post",
    image_path: "/images/blog/escaping_tutorials.jpg",
    category_id: dev_category.id,
    status: "draft"
  }
]

# Create blog posts (only if they don't exist)
for post_attrs <- posts do
  existing_post = Post |> where([p], p.slug == ^post_attrs.slug) |> limit(1) |> Repo.one()
  
  case existing_post do
    nil ->
      changeset = Post.changeset(%Post{}, post_attrs)
      case Repo.insert(changeset) do
        {:ok, _post} -> IO.puts("Post '#{post_attrs.title}' created.")
        {:error, changeset} -> IO.inspect(changeset.errors, label: "Failed to create post '#{post_attrs.title}'")
      end
    _existing -> IO.puts("Post '#{post_attrs.title}' already exists, skipping.")
  end
end

# Create photo categories
photo_categories = [
  %{name: "Me", slug: "me", description: "Personal photos and moments", color: "#10b981"},
  %{name: "Cooking", slug: "cooking", description: "Food and cooking adventures", color: "#f97316"},
  %{name: "Travel", slug: "travel", description: "Travel and adventure photos", color: "#3b82f6"}
]

created_categories = Enum.map(photo_categories, fn category_attrs ->
  case Repo.get_by(PhotoCategory, slug: category_attrs.slug) do
    nil -> 
      %PhotoCategory{}
      |> PhotoCategory.create_changeset(category_attrs)
      |> Repo.insert!()
    existing -> existing
  end
end)

# Get category IDs for photos
me_category = created_categories |> Enum.find(&(&1.slug == "me"))
cooking_category = created_categories |> Enum.find(&(&1.slug == "cooking"))

photos = [
  %{description: "The coolest thing I've ever done was officiate my friends wedding.", photo_category_id: me_category.id, image_path: "/images/about/wedding.jpg", width: 1600, height: 1200, aspect_ratio: 1.33, priority_score: 10, visual_weight: "heavy", focal_point_x: 0.5, focal_point_y: 0.4},
  %{description: "Mat's my best bud.", photo_category_id: me_category.id, image_path: "/images/about/me_with_mat.jpg", width: 1200, height: 1600, aspect_ratio: 0.75, priority_score: 7, visual_weight: "medium", focal_point_x: 0.6, focal_point_y: 0.35},
  %{description: "I'm an uncle now!", photo_category_id: me_category.id, image_path: "/images/about/me_with_rosie.jpg", width: 1200, height: 1600, aspect_ratio: 0.75, priority_score: 8, visual_weight: "medium", focal_point_x: 0.6, focal_point_y: 0.35},
  %{description: "Speech at my sister's wedding.", photo_category_id: me_category.id, image_path: "/images/about/me_with_eileen_wedding.jpg", width: 1600, height: 1200, aspect_ratio: 1.33, priority_score: 9, visual_weight: "heavy", focal_point_x: 0.6, focal_point_y: 0.35},
  %{description: "Hitting the gym to stay strong.", photo_category_id: me_category.id, image_path: "/images/about/me_at_gym.jpg", width: 1200, height: 1600, aspect_ratio: 0.75, priority_score: 6, visual_weight: "medium", focal_point_x: 0.5, focal_point_y: 0.35},
  %{description: "My girlfriend and I giving free labour to apple orchards.", photo_category_id: me_category.id, image_path: "/images/about/me_with_annie.jpg", width: 1200, height: 1600, aspect_ratio: 0.75, priority_score: 7, visual_weight: "medium", focal_point_x: 0.6, focal_point_y: 0.35},
  %{description: "Abu Dhabi was a little too sunny to keep my eyes open for photos.", photo_category_id: me_category.id, image_path: "/images/about/me_in_abu_dhabi.jpeg", width: 1920, height: 1080, aspect_ratio: 1.78, priority_score: 6, visual_weight: "medium", focal_point_x: 0.5, focal_point_y: 0.6},
  %{description: "Moments before they threw me headfirst into the pool.", photo_category_id: me_category.id, image_path: "/images/about/me_with_friends.jpg", width: 1600, height: 1200, aspect_ratio: 1.33, priority_score: 7, visual_weight: "medium", focal_point_x: 0.6, focal_point_y: 0.35},
  %{description: "I thought we were going to a baptism.", photo_category_id: me_category.id, image_path: "/images/about/me_surprised.jpeg", width: 1200, height: 1600, aspect_ratio: 0.75, priority_score: 8, visual_weight: "heavy", focal_point_x: 0.5, focal_point_y: 0.35},
  %{description: "I didn't know what to do with all the leftover polenta.", photo_category_id: cooking_category.id, image_path: "/images/about/beef_and_polenta.jpg", width: 1200, height: 1200, aspect_ratio: 1.0, priority_score: 5, visual_weight: "light", focal_point_x: 0.5, focal_point_y: 0.5},
  %{description: "Pretty spot on Beef Wellington.", photo_category_id: cooking_category.id, image_path: "/images/about/beef_wellington.jpg", width: 1200, height: 1200, aspect_ratio: 1.0, priority_score: 6, visual_weight: "light", focal_point_x: 0.5, focal_point_y: 0.5},
  %{description: "There's a million ways to make chicken and rice but this one is the best way.", photo_category_id: cooking_category.id, image_path: "/images/about/chicken_and_rice.jpg", width: 1200, height: 1200, aspect_ratio: 1.0, priority_score: 5, visual_weight: "light", focal_point_x: 0.5, focal_point_y: 0.5},
  %{description: "General Tso's Chicken.", photo_category_id: cooking_category.id, image_path: "/images/about/general_tsos.jpg", width: 1200, height: 1200, aspect_ratio: 1.0, priority_score: 4, visual_weight: "light", focal_point_x: 0.5, focal_point_y: 0.5},
  %{description: "Japanese Curry.", photo_category_id: cooking_category.id, image_path: "/images/about/japanese_curry.jpg", width: 1200, height: 1200, aspect_ratio: 1.0, priority_score: 4, visual_weight: "light", focal_point_x: 0.5, focal_point_y: 0.5},
  %{description: "The best leek and potato soup recipe courtesy of Chef Jack Ovens.", photo_category_id: cooking_category.id, image_path: "/images/about/leek_and_potato_soup.jpg", width: 1200, height: 1200, aspect_ratio: 1.0, priority_score: 4, visual_weight: "light", focal_point_x: 0.5, focal_point_y: 0.5},
  %{description: "A summer pasta recipe I found on Instagram.", photo_category_id: cooking_category.id, image_path: "/images/about/summer_pasta.jpg", width: 1200, height: 1200, aspect_ratio: 1.0, priority_score: 5, visual_weight: "light", focal_point_x: 0.5, focal_point_y: 0.5},
  %{description: "Thanksgiving Dinner 2023.", photo_category_id: cooking_category.id, image_path: "/images/about/thanksgiving_dinner.jpg", width: 1600, height: 1200, aspect_ratio: 1.33, priority_score: 6, visual_weight: "medium", focal_point_x: 0.5, focal_point_y: 0.5}
]

# Create photos (only if they don't exist)
for photo_attrs <- photos do
  case Repo.get_by(Photo, image_path: photo_attrs.image_path) do
    nil ->
      case Repo.insert(Photo.changeset(%Photo{}, photo_attrs)) do
        {:ok, _photo} -> IO.puts("Photo created: #{photo_attrs.description}")
        {:error, changeset} -> IO.inspect(changeset.errors, label: "Failed to create photo")
      end
    _existing -> IO.puts("Photo already exists: #{photo_attrs.description}")
  end
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
