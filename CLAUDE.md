# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

This is a Phoenix/Elixir web application. Essential commands:

- `mix setup` - Install dependencies and setup the database (creates DB, runs migrations, installs assets)
- `mix phx.server` - Start the development server on localhost:4000
- `iex -S mix phx.server` - Start server with interactive Elixir shell
- `mix test` - Run all tests (automatically creates test DB and runs migrations)
- `mix ecto.reset` - Reset database (drop, create, migrate, seed)
- `mix assets.build` - Build frontend assets (Tailwind CSS + ESBuild)
- `mix assets.deploy` - Build and minify assets for production

## Architecture Overview

This is a Phoenix LiveView personal website/blog with the following structure:

### Core Application Structure
- **Phoenix LiveView**: Modern real-time web framework for Elixir
- **Ecto**: Database ORM with PostgreSQL
- **Tailwind CSS**: Utility-first CSS framework
- **ESBuild**: JavaScript bundling

### Key Modules
- `Website.Application` - OTP application supervisor tree
- `WebsiteWeb.Router` - Route definitions for LiveView pages
- `Website.Repo` - Database repository interface
- `Website.Blog.*` - Blog functionality (posts, categories)
- `Website.Photo` - Photo gallery functionality

### LiveView Pages
Routes defined in `lib/website_web/router.ex:17-27`:
- `/` - SplashLive (homepage)
- `/about` - AboutLive 
- `/work` - WorkLive
- `/blog` - BlogLive.Index
- `/blog/posts/:id` - BlogLive.Show
- `/projects` - ProjectsLive (routes have typo: "Indexs")

### Database Schema
- `posts` table with title, body, slug, image_path, read_time, description
- `categories` table for blog post categorization  
- `photos` table for gallery functionality
- Migrations in `priv/repo/migrations/`

### Frontend Assets
- Static assets in `priv/static/`
- Source assets in `assets/`
- Custom font: Indie Flower for headings
- Images organized by section (about/, blog/)

## Development Notes

- Blog posts automatically calculate read time based on word count (200 words/minute)
- Development dashboard available at `/dev/dashboard` 
- LiveReload enabled for development
- Database seeds in `priv/repo/seeds.exs`
- Tests use separate test database (automatically managed)