# Personal Website

A modern, responsive personal portfolio and blog built with Phoenix LiveView, featuring a playful design with excellent accessibility and performance.

## Features

### 📝 **Blog System**
- Database-driven blog with categories and posts
- Trix editor for WYSIWYG content creation
- Documentation-style syntax highlighting with dark themes
- Automatic read time calculation based on word count
- SEO-optimized with meta descriptions and structured data
- Accessible article reading component with optimized typography
- Admin panel for content management

### 🛠️ **Admin Interface**
- Secure admin dashboard for content management
- Create, edit, and manage blog posts with live preview
- Category management system
- Draft and published post status tracking
- Real-time form validation with LiveView

### 🚀 **Projects Showcase**
- Database-driven projects with technologies and status tracking
- Many-to-many relationships between projects and technologies
- Featured project highlighting
- Technology stack visualization

### 📸 **Photo Gallery**
- Category-based photo organization
- Interactive filtering system
- Responsive collage-style layout with varied image sizes
- Hover effects and smooth transitions


### 🏗️ **Technical Stack**
- **Backend**: Elixir + Phoenix LiveView
- **Database**: PostgreSQL with Ecto
- **Frontend**: TailwindCSS + ESBuild + Trix Editor
- **Real-time**: Phoenix PubSub and LiveView
- **Typography**: Custom fonts (Indie Flower, Inter, JetBrains Mono)
- **JavaScript**: Minimal vanilla JS with LiveView hooks

## Setup Instructions

### Prerequisites
- Elixir 1.15+ and Erlang/OTP 26+
- PostgreSQL 14+
- Node.js 18+ (for asset compilation)

### Installation

1. **Clone and install dependencies:**
   ```bash
   git clone <repository-url>
   cd website
   mix setup  # Installs deps, creates DB, runs migrations, seeds data
   ```

2. **Start the development server:**
   ```bash
   mix phx.server
   # Or with interactive shell:
   iex -S mix phx.server
   ```

3. **Visit the application:**
   - Main site: [localhost:4000](http://localhost:4000)
   - Admin panel: [localhost:4000/admin](http://localhost:4000/admin)
   - Development dashboard: [localhost:4000/dev/dashboard](http://localhost:4000/dev/dashboard)

### Development Commands

- `mix test` - Run all tests (automatically creates test DB)
- `mix ecto.reset` - Reset database (drop, create, migrate, seed)
- `mix assets.build` - Build frontend assets (Tailwind CSS + ESBuild)
- `mix assets.deploy` - Build and minify assets for production
- `iex -S mix phx.server` - Start server with interactive Elixir shell

## Architecture & Key Components

### 🏗️ **Application Structure**
- **LiveView Pages**: Splash, About, Work, Blog, Projects
- **Admin Interface**: Content management with real-time updates
- **Database Schema**: Posts, categories, photos with proper relationships
- **Custom Components**: Trix editor, markdown preview, responsive galleries
- **Styling System**: Custom design tokens with Tailwind utilities

### 📂 **Key Directories**
- `lib/website_web/live/` - LiveView pages and admin interface
- `lib/website_web/components/` - Reusable UI components
- `lib/website/` - Business logic (Blog, Photo modules)
- `assets/` - Frontend assets (CSS, JS, images)
- `priv/repo/` - Database migrations and seeds

## What's Next

### 🎯 **Immediate Roadmap**

2. **RSS Feed**
   - XML feed generation for blog posts
   - Automatic updates on new posts
   - Feed discovery metadata

4. **Performance Enhancements**
   - Image optimization and CDN integration
   - Caching strategies for static content
   - Database query optimizations

## Tech Stack References

- [Phoenix Framework](https://www.phoenixframework.org/) - Web framework
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/) - Real-time web applications
- [Ecto](https://hexdocs.pm/ecto/) - Database wrapper and query generator
- [TailwindCSS](https://tailwindcss.com/) - Utility-first CSS framework
- [Trix Editor](https://trix-editor.org/) - Rich text editor for content creation
- [PostgreSQL](https://www.postgresql.org/) - Relational database