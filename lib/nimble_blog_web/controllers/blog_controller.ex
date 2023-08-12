defmodule NimbleBlogWeb.BlogController do
  use NimbleBlogWeb, :controller

  alias NimbleBlog.Blog

  def index(conn, _params), do: render(conn, "index.html", posts: Blog.all_posts())

  def show(conn, %{"id" => id}), do: render(conn, "show.html", post: Blog.get_post_by_id!(id))

  def tag_filter(conn, %{"tag" => tag}),
    do: render(conn, "index.html", posts: Blog.get_posts_by_tag!(tag))
end
