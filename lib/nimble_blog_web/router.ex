defmodule NimbleBlogWeb.Router do
  use NimbleBlogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {NimbleBlogWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :social_web do
    plug :accepts, ["json"]
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_resp_content_type, "application/activity+json"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NimbleBlogWeb do
    pipe_through :browser

    get "/", BlogController, :index
    get "/post/:id/:lang", BlogController, :show

    get "/lang/:lang/tag/:tag", BlogController, :filter
  end

  scope "/", NimbleBlogWeb do
    pipe_through :social_web

    get "/.well-known/webfinger", ActivityPubController, :webfinger
    get "/@blog", ActivityPubController, :actor
    post "/socialweb/inbox", ActivityPubController, :inbox
    get "/socialweb/outbox", ActivityPubController, :outbox
  end

  # Other scopes may use custom stacks.
  # scope "/api", NimbleBlogWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:nimble_blog, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: NimbleBlogWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
