%{
  title: "Create your own HTTP codes in Phoenix with Plug",
  author: "Simon Tirant",
  tags: ~w(elixir phoenix plug web http),
  lang: "english",
  description: "Bored of `404 not found` and other `500 internal server error`? Well, be creative and invent your own HTTP status code inside your Phoenix app with Plug!",
  illustration: "/images/posts/error.gif",
  illustration_alt: "Animated error message"
}
---
By default - inside your [Phoenix](https://www.phoenixframework.org/) app - most of the exceptions raised are `500` errors: the notorious `Internal Server Error`, meaning that the website developer is a naughty programer who made some mistakes and forgot to reread his own code. But hey! Sometimes it's also the visitor fault! So please don't bite the hand who's feeding you with such nice content and navigate knowing where you are going!

Well, in my case I wanted to raise two other kinds of exceptions than `500`: the first one was the famous `404 Not Found`, but I also decided to create a custom and more specific `461 No Blog Posts Found`. Here is my story... 📖

![Old book opening](/images/posts/old_book.webp)

### 404 101 🧑‍🎓

For the first one, I wanted to raise an exception when a specific article was not found for a specific language. For example, I manage translation on this blog with the uri path; look at the address bar: the post you are currently reading has a domain name `blog.simontirant.dev` / then the `post` route / then the article id (`custom_http_codes`) / finally the language attribute which can be either `english` or `french`. If you decide - for some reasons - to change this last path attribute to write `silbo` instead (for the record, the *silbo* is an antique whistled language used in Gomera, one of the Canary islands), then the server will raise that `404 Not Found` exception - instead of the default `500` - because, even if I could still learn this language online and record my tech article into an audio file so you could listen to it through a web audio player, I'm not really sure that there would be an audience for that.

Concretly, my `show/2` function from my `BlogController` calls another function, located inside the `Blog` module, nammed `get_post_by_id_and_lang!/2`, by passing the article id and language path attributes to it as parameters. This `Blog.get_post_by_id_and_lang!/2` is then responsible to retrieve the article by its id and language (because two articles can share the same id if they are in different languages), if `nil` it raises an exception called `NotFoundError` which was previously declared into its own module. Here is an extract of my code below:

```elixir
defmodule NimbleBlog.Blog do

  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})

  def all_posts, do: @posts

  defmodule NotFoundError, do: defexception([:message, plug_status: 404])

  @doc """
  Returns a specific %Post{} from the combination of its id and language.
  Raise if nothing is found.

  #### Example:
      iex> get_post_by_id_and_lang!("post_1", "english")
      %Post{}

      iex> get_post_by_id_and_lang!("post_1", "german")
      ** (NotFoundError) post with both id="post_1" and lang="german" not found
  """
  @spec get_post_by_id_and_lang!(String.t(), String.t()) :: %Post{} | NotFoundError
  def get_post_by_id_and_lang!(id, lang) do
    Enum.find(all_posts(), &(&1.id == id && &1.lang == lang)) ||
      raise NotFoundError, "post with both id=#{id} and lang=#{lang} not found"
  end
end
```

*P.S.: this blog uses the [NimblePublisher](https://hex.pm/packages/nimble_publisher) library to render blog posts from [Markdown](https://daringfireball.net/projects/markdown/) files stored inside a folder. As I don't use a database, there is no [Ecto](https://hexdocs.pm/ecto/Ecto.html) functions such as `Repo.get!/3` but functions from the `Enum` module instead. [Read the first part of my article on NimblePublisher here](https://blog.simontirant.dev/post/nimble_blog_1/english).*

As we can see, the exception I have declared as `NotFoundError` is related to a classic old `404` [HTTP code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status), this because of the `plug_status: 404` option I have set just after `:message` in my exception declaration. The `404` is a very common [HTTP code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status) and [Plug](https://hexdocs.pm/plug/readme.html) already knows it, look at the top of the `Plug.Conn.Status` module, located into the `deps` folder:

```elixir
  statuses = %{
    ...
    400 => "Bad Request",
    401 => "Unauthorized",
    402 => "Payment Required",
    403 => "Forbidden",
    404 => "Not Found",
    405 => "Method Not Allowed",
    406 => "Not Acceptable",
    407 => "Proxy Authentication Required",
    408 => "Request Timeout",
    409 => "Conflict",
    410 => "Gone",
    411 => "Length Required",
    412 => "Precondition Failed",
    413 => "Request Entity Too Large",
    414 => "Request-URI Too Long",
    415 => "Unsupported Media Type",
    416 => "Requested Range Not Satisfiable",
    417 => "Expectation Failed",
    418 => "I'm a teapot",
    421 => "Misdirected Request",
    422 => "Unprocessable Entity",
    423 => "Locked",
    424 => "Failed Dependency",
    425 => "Too Early",
    426 => "Upgrade Required",
    428 => "Precondition Required",
    429 => "Too Many Requests",
    431 => "Request Header Fields Too Large",
    451 => "Unavailable For Legal Reasons",
    ...
  }
```

It means that if my function fails to retrieve a blog post for this id and this language - meaning that the `post` route is good but at least one of the path arguments is wrong - then the exception `NotFoundError` is raised, calling [Plug](https://hexdocs.pm/plug/readme.html)'s `404` status and then [Phoenix](https://www.phoenixframework.org/) redirects the user to the `404.html.heex` view I created inside my `error_html` folder, located in the `controllers` folder. To call this specific template, you have to go in the `error_html.ex` view (still in the `controllers` folder) and to add `embed_templates("error_html/*")` - instead of the `render/2` function already written. With that, [Phoenix](https://www.phoenixframework.org/) can display the templates from the `error_html` folder for your custom error pages ([link to the dedicated page in docs](https://hexdocs.pm/phoenix/1.7.7/custom_error_pages.html)).

This mecanism, consisting in calling the [Plug](https://hexdocs.pm/plug/readme.html)'s `404` status from an exception, [Phoenix](https://www.phoenixframework.org/) also do it for a `NoRouteError` - a native exception raised by the `Phoenix.Router` module when a simple route just doesn't exist: for example, if you wrote `/pist` instead of `/post` in the url. In our case, the id and the language being parameters and not a route, a wrong term would have natively raised a `500` error and not a `404` one; but I could have actually decided to import and raise in my `Blog` module the `Phoenix.Router.NotFoundError` native exception, instead of creating my own, because it also calls [Plug](https://hexdocs.pm/plug/readme.html)'s `404` status.

But, if you actually looked at the top of the `Plug.Conn.Status` of any [Phoenix](https://www.phoenixframework.org/) project, you must have seen this just before the statuses list: 

```elixir
  custom_statuses = Application.compile_env(:plug, :statuses, %{})
```

Do you know what it means? It means that even if the standard [HTTP codes list](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status) anticipated some private jokes - like `418 I'm a teapot` or, my favorite, `451 Unavailable For Legal Reasons` ... the state censorship in _Fahrenheit 451_, do you get it ? - so you can have fun with them, it lets a lot of available codes to make your own bizarre statuses.

### Ready to play with numbers ? 🧮

Well, I also needed to raise an error when the results of a tag filter is empty for a specific language. So, if you click - for example - on the `knitting 🧶` tag then on the `english 🇬🇧` flag to only have blog posts about knitting in english, well you'll raise my custom `461 No Blog Posts Found` [HTTP code]((https://developer.mozilla.org/en-US/docs/Web/HTTP/Status))... Because I haven't written a post in english on this topic yet. And because this is a tech blog, the exception would have been raised for `french 🇫🇷` language too! That code, like the `404`, will then call the `461.html.heex` view from the `error_html` folder explaining you that the server haven't found any articles for your request.

But ... How did I do that ? Is this **black magic** ? *Boooo...*🕷️🔮🪄🧿

Well, actually no. This is just done by using the `Config.config/3` function for [Plug](https://hexdocs.pm/plug/readme.html) statuses inside the `config.exs` file in the `config` folder:

```elixir
import Config

config :plug, :statuses, %{461 => "No Blog Posts Found"}
```

This way, at compile time, [Plug](https://hexdocs.pm/plug/readme.html) will build its `statuses` map we saw earlier with the `404` [HTTP code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status), **but including this time** the custom statuses we passed to the `config.exs` file. As you may have understood, it is necessary to recompile [Plug](https://hexdocs.pm/plug/readme.html) dependency after this modification and, in my case, I had to use `mix deps.compile plug --force`, else `mix` returned an error without the `--force` flag. After that, I can do the following to my `Blog` module in order to filter the blog articles:

```elixir 
defmodule NimbleBlog.Blog do
  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})

  def all_posts, do: @posts

  defmodule NoBlogPostsError, do: defexception([:message, plug_status: 461])

  @doc """
  Gets the list of posts filtered by a specific tag or language or a combination of both.

  Example:
      iex> list_posts_by_filters!(%{tag: "elixir", lang: "english"})
      [%Post{lang: "english", tags: ["elixir", ...]}, ...]

      iex> list_posts_by_filters!(%{tag: "cooking", lang: "sumerian"})
      ** (NoBlogPostsError) posts no found with tag cooking in sumerian language.
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

  defp list_posts_by_tag!(tag) do
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
end
```

As for the `404` code, I declared my `NoBlogPostsError` exception into its own module and I used this time the `plug_status: 461` option to call the custom status we have set before in `config.exs`. The functions responsible to render the `%Post{}` list - filtered by language, tag or both - can then raise the exception module `NoBlogPostsError` in case the `%Post{}` list is empty.

*N.B.: this method, to add custom codes which are not used by the standard [HTTP codes list](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status), can also be used to create a different message for an existing code. This way, you can modify the `404 Not Found` for a cheeky `404 Found But Don't Want To Show It To You`; or again `451 Sorry But It Burned!`. Nice!*