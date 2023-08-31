defmodule NimbleBlogWeb.BlogController do
  use NimbleBlogWeb, :controller

  alias NimbleBlog.Blog

  def index(conn, _params) do
    posts =
      Blog.all_posts()
      |> Enum.reduce([], fn
        post, [head | _tail] = acc ->
          if head.date == post.date, do: acc, else: [post | acc]

        post, acc ->
          [post | acc]
      end)
      |> Enum.reverse()

    render(conn, "index.html", posts: posts, tag_filter: "all", lang_filter: "all")
  end

  def show(conn, %{"id" => id}),
    do:
      render(conn, "show.html",
        post: Blog.get_post_by_id!(id),
        tag_filter: "all",
        lang_filter: "all"
      )

  def filter(conn, %{"lang" => lang, "tag" => tag} = filter_map) do
    render(conn, "index.html",
      posts: Blog.get_posts_by_filters!(filter_map),
      tag_filter: tag,
      lang_filter: lang
    )
  end
end
