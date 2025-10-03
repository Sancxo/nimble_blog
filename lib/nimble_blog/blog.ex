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

  @img_read_time 12
  @words_read_time 265

  # And finally export them
  def all_posts, do: @posts
  def count_all_unique_posts, do: all_posts() |> Enum.dedup_by(& &1.id) |> Enum.count()
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
  defmodule NoBlogPostsError, do: defexception([:message, plug_status: 461])

  @deprecated "Use get_post_by_id_and_lang/2 instead to distinguish english and french version of the same article when they share the same id."
  def get_post_by_id!(id) do
    Enum.find(all_posts(), &(&1.id == id)) ||
      raise NotFoundError, "post with id=#{id} not found"
  end

  def get_post_by_id_and_lang!(id) do
    Enum.find(all_posts(), &(&1.id == id)) ||
      raise NotFoundError, "post with id=#{id} not found"
  end

  @doc ~S"""
  Returns a specific %Post{} from the combination of its id and language.
  Raise if nothing is found.

  #### Example:

      iex> get_post_by_id_and_lang!("test_1", "english")
      %Post{id: "test_1", lang: "english", author: "Simon Tirant", title: "Test 1", body: "<p>\nTest!</p>\n", illustration: "", description: "This is a test.", tags: ["test"], date: ~D[2023-01-01]}

      iex> get_post_by_id_and_lang!("post_1", "german")
      ** (NimbleBlog.Blog.NotFoundError) post with both id=post_1 and lang=german not found
  """
  @spec get_post_by_id_and_lang!(String.t(), String.t()) :: %Post{} | NotFoundError
  def get_post_by_id_and_lang!(id, lang) do
    Enum.find(all_posts(), &(&1.id == id && &1.lang == lang)) ||
      raise NotFoundError, "post with both id=#{id} and lang=#{lang} not found"
  end

  @spec get_post_by_id_and_lang(String.t(), String.t()) :: %Post{} | nil
  defp get_post_by_id_and_lang(id, lang) do
    all_posts() |> Enum.find(&(&1.id == id && &1.lang == lang)) || nil
  end

  @doc ~S"""
  Returns the other language version of the blog post if exists, if not returns `nil`.

  #### Example:

      iex> check_for_translation("test_1", "french")
      %Post{id: "test_1", lang: "english", author: "Simon Tirant", title: "Test 1", body: "<p>\nTest!</p>\n", illustration: "", description: "This is a test.", tags: ["test"], date: ~D[2023-01-01]}

      iex> check_for_translation("test_2", "french")
      nil
  """
  @spec check_for_translation(String.t(), String.t()) :: %Post{} | nil
  def check_for_translation(id, lang) do
    alt_lang = (lang == "english" && "french") || "english"

    get_post_by_id_and_lang(id, alt_lang)
  end

  @doc ~S"""
  Gets the list of posts filtered by a specific tag or language or a combination of both.

  Example:

      iex> list_posts_by_filters!(%{"tag" => "test", "lang" => "english"})
      [%Post{id: "test_1", lang: "english", author: "Simon Tirant", title: "Test 1", body: "<p>\nTest!</p>\n", illustration: "", description: "This is a test.", tags: ["test"], date: ~D[2023-01-01]}]

      iex> list_posts_by_filters!(%{"tag" => "cooking", "lang" => "sumerian"})
      ** (NimbleBlog.Blog.NoBlogPostsError) posts no found with tag cooking in sumerian language.
  """
  @spec list_posts_by_filters!(%{tag: String.t() | nil, lang: String.t() | nil}) ::
          [%Post{}] | NoBlogPostsError
  def list_posts_by_filters!(%{"tag" => "all", "lang" => "all"}), do: all_posts()
  def list_posts_by_filters!(%{"tag" => "all", "lang" => lang}), do: lang |> list_posts_by_lang!()
  def list_posts_by_filters!(%{"tag" => tag, "lang" => "all"}), do: tag |> list_posts_by_tag!()

  def list_posts_by_filters!(%{"tag" => tag, "lang" => lang}) do
    all_posts()
    |> Enum.filter(&(lang == &1.lang))
    |> Enum.filter(&(tag in &1.tags))
    |> case do
      [] -> raise NoBlogPostsError, "posts no found with tag #{tag} in #{lang} language."
      posts -> posts
    end
  end

  def list_posts_by_tag!(tag) do
    case Enum.filter(all_posts(), &(tag in &1.tags)) do
      [] -> raise NoBlogPostsError, "posts with tag=#{tag} not found"
      posts -> posts
    end
  end

  defp list_posts_by_lang!(lang) do
    case Enum.filter(all_posts(), &(lang == &1.lang)) do
      [] -> raise NoBlogPostsError, "posts for #{lang} language not found"
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

  def get_reading_duration(post) do
    img_time =
      ~r/<(img)([\w\W]+?)[\/]?>/
      |> Regex.scan(post, capture: :first)
      |> Enum.count()
      |> case do
        count when count > 10 ->
          (count / 2 * (@img_read_time + 3) + (count - 10) * 3) / 60

        count ->
          count / 2 * (2 * @img_read_time + (1 - count)) / 60
      end

    html_tag_pattern = ~r/<\w+(\s+("[^"]*"|\\'[^\\']*\'|[^>])+)?>|<\/\w+>/i

    untagged_post =
      post
      |> String.trim()
      |> String.replace(html_tag_pattern, "")

    word_count =
      ~r/\w+/
      |> Regex.scan(untagged_post, capture: :first)
      |> Enum.count()

    word_time = word_count / @words_read_time

    (img_time + word_time)
    |> case do
      time when time < 0.5 ->
        "< 1"

      time ->
        "#{time |> round()}"
    end
  end
end
