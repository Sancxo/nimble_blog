defmodule NimbleBlogWeb.PageController do
  use NimbleBlogWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    # render(conn, :home, layout: false)
    render(conn, external: "https://simontirant.dev/")
  end
end
