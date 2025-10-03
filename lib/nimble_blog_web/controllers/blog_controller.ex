defmodule NimbleBlogWeb.BlogController do
  use NimbleBlogWeb, :controller

  alias NimbleBlog.Blog

  def index(conn, _params) do
    # I chose to remove duplicated elements by id (the last part of the name file).
    # It means that both english and french version of the article should have the same id (warning!).
    # It also means that I have to get one article, in the show function,
    # by the combination of its id and language instead of just the id.
    # Another solution is to remove them by date as I will not publish 2 different articles the same day,
    # but both versions will share the same publishing date.
    posts = Blog.all_posts() |> Enum.dedup_by(& &1.id)

    render(conn, "index.html", posts: posts, tag_filter: "all", lang_filter: "all")
  end

  def tags(conn, %{"tag" => tag}),
    do:
      render(conn, "index.html",
        posts: Blog.list_posts_by_tag!(tag) |> Enum.dedup_by(& &1.id),
        tag_filter: tag,
        lang_filter: "all"
      )

  def show(conn, %{"id" => id, "lang" => lang}),
    do:
      render(conn, "show.html",
        post: Blog.get_post_by_id_and_lang!(id, lang),
        tag_filter: "all",
        lang_filter: "all"
      )

  def show(conn, %{"id" => id}),
    do:
      render(conn, "show.html",
        post: Blog.get_post_by_id!(id),
        tag_filter: "all",
        lang_filter: "all"
      )

  def filter(conn, %{"lang" => lang, "tag" => tag} = filter_map) do
    render(conn, "index.html",
      posts: Blog.list_posts_by_filters!(filter_map) |> Enum.dedup_by(& &1.id),
      tag_filter: tag,
      lang_filter: lang
    )
  end
end
