defmodule WebsiteWeb.Router do
  @moduledoc """
  Main router for the Website application.

  Organizes routes into logical groups:
  - Public routes (/, /about, /blog, etc.)
  - Authentication routes (/users/*)
  - Admin routes (/admin/*)
  - API routes (/api/*, /feed.xml)
  - Development routes (dev mode only)
  """

  use WebsiteWeb, :router

  import WebsiteWeb.UserAuth

  # ============================================================================
  # PIPELINES
  # ============================================================================

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {WebsiteWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json", "xml"]
  end

  pipeline :api_v1 do
    plug :accepts, ["json"]
  end

  # ============================================================================
  # PUBLIC ROUTES - Main website content
  # ============================================================================

  scope "/", WebsiteWeb do
    pipe_through :browser

    # Core pages
    live "/", SplashLive, as: :home
    live "/about", AboutLive
    live "/work", WorkLive
    live "/projects", ProjectsLive

    # Blog functionality
    live "/blog", BlogLive.Index
    live "/blog/posts/:id", BlogLive.Show
  end

  # ============================================================================
  # FEEDS & API ROUTES - External integrations
  # ============================================================================

  scope "/", WebsiteWeb do
    pipe_through :api

    # RSS/Atom feeds (maintaining backward compatibility with /feed.xml)
    get "/feed.xml", RSSController, :feed
    get "/feed.atom", RSSController, :atom
  end

  scope "/api", WebsiteWeb do
    pipe_through :api

    # Health check endpoint for monitoring
    get "/health", HealthController, :check
  end

  # Future API versioning structure
  scope "/api/v1", WebsiteWeb.API.V1 do
    pipe_through :api_v1

    # Future JSON API endpoints will go here
    # get "/posts", PostController, :index
    # get "/categories", CategoryController, :index
  end

  # ============================================================================
  # AUTHENTICATION ROUTES - User login, settings, logout
  # ============================================================================

  scope "/users", WebsiteWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/log_in", UserSessionController, :new
    post "/log_in", UserSessionController, :create
  end

  scope "/users", WebsiteWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/settings", UserSettingsController, :edit
    put "/settings", UserSettingsController, :update
    get "/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/users", WebsiteWeb do
    pipe_through [:browser]

    delete "/log_out", UserSessionController, :delete
  end

  # ============================================================================
  # ADMIN ROUTES - Content management interfaces
  # ============================================================================

  scope "/admin", WebsiteWeb do
    pipe_through [:browser, :require_authenticated_user]

    # Main admin dashboard
    live "/", AdminLive, as: :admin_home

    # Content management
    live "/photos", AdminPhotosLive, as: :admin_photos
    live "/projects", AdminProjectsLive, as: :admin_projects

    # Blog management
    live "/blog", AdminBlogLive, as: :admin_blog
    live "/blog/new", AdminBlogLive.New, as: :admin_blog_new
    live "/blog/edit/:id", AdminBlogLive.Edit, as: :admin_blog_edit
    live "/categories", AdminCategoriesLive, as: :admin_categories
  end

  # ============================================================================
  # DEVELOPMENT ROUTES - Only available in development environment
  # ============================================================================

  if Application.compile_env(:website, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev", WebsiteWeb do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: WebsiteWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
