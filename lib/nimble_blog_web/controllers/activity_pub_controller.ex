defmodule NimbleBlogWeb.ActivityPubController do
  use NimbleBlogWeb, :controller

  def webfinger(conn, _) do
    render(conn, :webfinger)
  end

  def actor(conn, _) do
    render(conn, :actor)
  end

  def outbox(conn, _) do
    render(conn, :outbox)
  end
end
