defmodule WebsiteWeb.Router do
  use WebsiteWeb, :router

  import WebsiteWeb.UserAuth

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


  scope "/", WebsiteWeb do
    pipe_through :browser

    live "/", SplashLive
    live "/about", AboutLive
    live "/work", WorkLive
    live "/blog", BlogLive.Index
    live "/blog/posts/:id", BlogLive.Show
    live "/projects", ProjectsLive
  end

  scope "/", WebsiteWeb do
    pipe_through :api

    get "/feed.xml", RSSController, :feed
  end


  # Other scopes may use custom stacks.
  # scope "/api", WebsiteWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:website, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: WebsiteWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", WebsiteWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
  end

  scope "/", WebsiteWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", WebsiteWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end

  scope "/admin", WebsiteWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/", AdminLive
    live "/photos", AdminPhotosLive
    live "/projects", AdminProjectsLive
    
    live "/blog", AdminBlogLive
    live "/blog/new", AdminBlogLive.New
    live "/blog/edit/:id", AdminBlogLive.Edit
    live "/categories", AdminCategoriesLive
  end
end
