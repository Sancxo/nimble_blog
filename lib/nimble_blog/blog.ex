defmodule NimbleBlog.Blog do
  alias NimbleBlog.Blog.Post

  use NimblePublisher,
    build: Post,
    from: Application.app_dir(:nimble_blog, "priv/posts/**/*.md"),
    as: :posts,
    highlighters: [:makeup_elixir, :makeup_erlang]

  # The @posts variable is first defined by NimblePublisher.
  # Let's further modify it by sorting all posts by descending date.
  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})

  # Let's also get all tags
  @tags @posts |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  # And finally export them
  def all_posts, do: @posts
  def all_tags, do: @tags

  # Important: Avoid injecting the @posts attribute into multiple functions, as each call will make a complete copy of all posts.
  # For example, if you want to show define recent_posts() as well as all_posts(), DO NOT do this:
  #
  # def all_posts, do: @posts
  # def recent_posts, do: Enum.take(@posts, 3)
  #
  # Instead do this:
  #
  # def all_posts, do: @posts
  # def recent_posts, do: Enum.take(all_posts(), 3)

  defmodule NotFoundError, do: defexception([:message, plug_status: 404])

  def get_post_by_id!(id) do
    Enum.find(all_posts(), &(&1.id == id)) ||
      raise NotFoundError, "post with id=#{id} not found"
  end

  def get_posts_by_tag!(tag) do
    case Enum.filter(all_posts(), &(tag in &1.tags)) do
      [] -> raise NotFoundError, "posts with tag=#{tag} not found"
      posts -> posts
    end
  end

  def get_time_from_now(date) do
    Date.utc_today()
    |> Date.diff(date)
    |> case do
      d when d == 0 -> "today"
      d when d < 31 -> "#{d} day(s) ago"
      m when m < 365 -> "#{(m / 31) |> floor()} month(s) ago"
      y -> "#{(y / 365) |> floor()} year(s) ago"
    end
  end
end
