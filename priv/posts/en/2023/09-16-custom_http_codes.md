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
By default - inside your [Phoenix](https://www.phoenixframework.org/) app - every exception raised is a `500` error; the notorious `Internal Server Error`, meaning that the website developer is a naughty programer who made some mistakes and forgot to reread his own code. But hey! Sometimes it's also the visitor fault! So please don't bite the hand who's feeding you with such nice content!

Well, in my case I wanted to raise two other kinds of exceptions: the first one was the famous `404 Not Found` but I also decided to create a custom and more specific `461 No Blog Posts Found`. Here is my story...

![Old book opening](/images/posts/old_book.webp)

### 404 101 🧑‍🎓

For the first one, I wanted to raise an exception when a specific article is not found for a specific language. For example, I manage translation on this blog with the uri path; look at the address bar: the post you are currently reading has a domain name / then the `post` route / then the article id (`custom_http_codes`) / finally the language attribute which can be either `english` or `french`. If you decide - for some reasons - to change this last path attribute to write `silbo` instead (for the record, the *silbo* is an antique whistled language used in Gomera, one of the Canary islands), then the server will raise that `404 Not Found` exception - instead of the default `500` - because, even if I could still learn this language online and record my tech article into an audio file so you could listen to it through a web audio player, I'm not really sure that there would be an audience for that.

Concretly, my `show/2` function from my `BlogController` calls another function from the `Blog` module, nammed `get_post_by_id_and_lang!/2`, by passing the article id and language path attributes to it as parameters. The `Blog.get_post_by_id_and_lang!/2` is then responsible to retrieve the article by its id and language (because two articles can share the same id if they are in different languages), if `nil` it raises an exception called `NotFoundError` which was previously declared in its own module. Here is an extract of my code below:

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

*P.S.: this blog uses the [NimblePublisher](https://hex.pm/packages/nimble_publisher) library to render blog posts from [Markdown](https://daringfireball.net/projects/markdown/) files stored inside a folder. As I don't use a database, there is no [Ecto](https://hexdocs.pm/ecto/Ecto.html) functions such as `Repo.get!/3` but functions from the `Enum` module instead.*

As we can see, the exception I have declared as `NotFoundError` is related to a classic old `404` [HTTP code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status), this because of the `plug_status: 404` option I have set just after the `:message` option. The `404` is a very common [HTTP code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status) and [Plug](https://hexdocs.pm/plug/readme.html) already knows it, look at the top of the `Plug.Conn.Status`, located into the `deps` folder:

```elixir
  statuses = %{
    100 => "Continue",
    101 => "Switching Protocols",
    102 => "Processing",
    103 => "Early Hints",
    200 => "OK",
    201 => "Created",
    202 => "Accepted",
    203 => "Non-Authoritative Information",
    204 => "No Content",
    205 => "Reset Content",
    206 => "Partial Content",
    207 => "Multi-Status",
    208 => "Already Reported",
    226 => "IM Used",
    300 => "Multiple Choices",
    301 => "Moved Permanently",
    302 => "Found",
    303 => "See Other",
    304 => "Not Modified",
    305 => "Use Proxy",
    306 => "Switch Proxy",
    307 => "Temporary Redirect",
    308 => "Permanent Redirect",
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
    500 => "Internal Server Error",
    501 => "Not Implemented",
    502 => "Bad Gateway",
    503 => "Service Unavailable",
    504 => "Gateway Timeout",
    505 => "HTTP Version Not Supported",
    506 => "Variant Also Negotiates",
    507 => "Insufficient Storage",
    508 => "Loop Detected",
    510 => "Not Extended",
    511 => "Network Authentication Required"
  }
```

It means that if my function fails to retrieve a blog post for this id and this language, meaning that the `post` route is good but at least one of the path arguments is wrong, then the `404` error is raised and [Phoenix](https://www.phoenixframework.org/) redirects the user to the corresponding `404.html.heex` view I created inside my `error_html` folder - located in the `controllers` folder - as it would have done for a standard `NoRouteError` - natively raised by the [Phoenix](https://www.phoenixframework.org/) `Router` module when the route is misspelled or just doesn't exists (and actually, I could have decided to import and raise `Phoenix.Router.NotFoundError`, because it also calls [Plug](https://hexdocs.pm/plug/readme.html)'s `404` status, instead of creating my own exeception).

But, if you actually looked at the top of the `Plug.Conn.Status` of any [Phoenix](https://www.phoenixframework.org/) project, you must have seen this just before the statuses list: 

```elixir
  custom_statuses = Application.compile_env(:plug, :statuses, %{})
```

Do you know what it means? It means that even if the standard [HTTP codes list](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status) anticipated some private jokes - like `418 I'm a teapot` or, my favorite, `451 Unavailable For Legal Reasons` ... the censorship in _Fahrenheit 451_, do you get it ? - so you can have fun with them, it lets a lot of available codes to make your own bizarre statuses.

### Ready to play with numbers ? 🧮

Well, I also needed to raise an error when the results of a tag filter is empty for a specific language. So, if you click - for example - on the `knitting 🧶` tag then on the `english 🇬🇧` flag to only have blog posts about knitting in english, well you'll raise my custom `461 No Blog Posts Found` [HTTP code]((https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)). And because this is a tech blog, the exception would have been raised for `french 🇫🇷` language too! That code, like the `404`, will then call the `461.html.heex` view from the `error_html` folder explaining you that the server haven't found any articles for your request.

But ... How did I do that ? Is this **black magic** ? *Boooo...*🕷️🔮🪄🧿

Well, actually no. This is just done by using the `Config.config/3` function for [Plug](https://hexdocs.pm/plug/readme.html) statuses inside the `config.exs` file in the `config` folder:

```elixir
import Config

config :plug, :statuses, %{461 => "No Blog Posts Found"}
```

This way, at compile time, [Plug](https://hexdocs.pm/plug/readme.html) will build its `statuses` map we saw earlier with the `404` [HTTP code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status), **but including this time** the statuses we passed to the `config.exs` file (as you may have understood, it is necessary to recompile [Plug](https://hexdocs.pm/plug/readme.html) after this modification). This way, I can do the following to my `Blog` module in order to filter the blog articles:

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

As for the `404` code, I declared my `NoBlogPostsError` exception into its own module and I used the `plug_status: 461` option to call the custom status we have set before in `config.exs`. The functions responsible to render the `%Post{}` list - filtered by language, tag or both - can then call the exception module in case the `%Post{}` list is empty.

*N.B.: this method, to add custom codes which are not used by the standard [HTTP codes list](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status), can also be used to create a different message for an existing code. This way, you can modify the `404 Not Found` for a cheeky `404 Found But Don't Want To Show It To You`; or again `451 Sorry But It Burned!`. Nice!*