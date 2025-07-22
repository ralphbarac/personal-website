# Personal Website

A modern, responsive personal portfolio and blog built with Phoenix LiveView, featuring a playful design with excellent accessibility and performance.

## Features

### 📝 **Blog System**
- Database-driven blog with categories and posts
- Automatic read time calculation
- Rich content support with optimized typography
- Accessible article reading component for optimal readability

### 🚀 **Projects Showcase**
- Database-driven projects with technologies and status tracking
- Many-to-many relationships between projects and technologies
- Featured project highlighting
- Technology stack visualization

### 📸 **Photo Gallery**
- Category-based photo organization
- Interactive filtering system
- Responsive image gallery with hover effects

### 🏗️ **Technical Stack**
- **Backend**: Elixir + Phoenix LiveView
- **Database**: PostgreSQL with Ecto
- **Frontend**: TailwindCSS + ESBuild
- **Real-time**: Phoenix PubSub and LiveView
- **Typography**: Custom fonts with excellent readability

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
   Open [localhost:4000](http://localhost:4000) in your browser

### Development Commands

- `mix test` - Run all tests
- `mix ecto.reset` - Reset database (drop, create, migrate, seed)
- `mix assets.build` - Build frontend assets
- `mix assets.deploy` - Build and minify assets for production

## What's Next

### 🎯 **Immediate Roadmap**

1. **Blog CRUD System**
   - Admin interface for creating/editing blog posts
   - Rich text editor integration
   - Draft/publish workflow
   - Category management

2. **User Management**
   - Authentication system
   - Admin user roles
   - Session management
   - Password reset functionality

3. **RSS Feed**
   - XML feed generation for blog posts
   - Automatic updates on new posts
   - Feed discovery metadata

4. **Recipe API**
   - RESTful API for recipe management
   - JSON schema for recipe data
   - Search and filtering capabilities
   - Integration with main site

## Tech Stack References

- [Phoenix Framework](https://www.phoenixframework.org/)
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/)
- [Ecto](https://hexdocs.pm/ecto/)
- [TailwindCSS](https://tailwindcss.com/)
- [PostgreSQL](https://www.postgresql.org/)
