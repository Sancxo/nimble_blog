defmodule NimbleBlogWeb.PageController do
  use NimbleBlogWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    redirect(conn, to: ~p"/")
    # render(conn, :home, layout: false)
  end
end
