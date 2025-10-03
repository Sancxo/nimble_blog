defmodule NimbleBlogWeb.ActivityPubController do
  use NimbleBlogWeb, :controller

  def webfinger(conn, _) do
    render(conn, :webfinger)
  end

  def actor(conn, _) do
    render(conn, :actor)
  end

  def outbox(conn, _) do
    posts_count = NimbleBlog.Blog.count_all_unique_posts()
    posts_list = NimbleBlog.Blog.all_posts() |> Enum.dedup_by(& &1.id)

    render(conn, :outbox, posts_count: posts_count, posts_list: posts_list)
  end

  def note(conn, %{"id" => id}) do
    render(conn, :note, id: id)
  end
end
