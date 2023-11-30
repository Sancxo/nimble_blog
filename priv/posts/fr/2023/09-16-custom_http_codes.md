%{
  title: "Créez vos propres codes HTTP dans Phoenix avec Plug",
  author: "Simon Tirant",
  tags: ~w(elixir phoenix plug web http),
  lang: "french",
  description: "Marre des `404 not found` et autres `500 internal server error`? Hé bien, soyez créatifs et inventez vos propres codes de status HTTP à l'intérieur de votre application Phoenix avec Plug!",
  illustration: "/images/posts/error.gif",
  illustration_alt: "Message d'erreur animé"
}
---
Par défaut - à l'intérieur de votre application [Phoenix](https://www.phoenixframework.org/) - la plupart des exceptions levées sont des erreurs `500`: la tristement célèbre `Internal Server Error`, indiquant que le développeur du site est un vilain programmeur qui a laissé des fautes dans son code et qui a oublié de se relire. Mais voilà, parfois c'est aussi la faute du visiteur! Alors s'il vous plaît, ne mordez pas la main qui vous nourrit avec du si bon contenu et naviguez en sachant où vous allez!

Donc, dans mon cas je voulais lever deux autres types d'exceptions que la `500`: la première était la fameuse `404 Not Found`, mais j'ai aussi décidé de créer une erreur personnalisée et plus spécifique `461 No Blog Posts Found` . Voici mon histoire ... 📖

![Vieux livre s'ouvrant](/images/posts/old_book.webp)

### 404 101 🧑‍🎓

Pour la première d'entre elles, je voulais lever une exception quand un article spécifique n'était pas trouvé pour une langue en particulier. Par exemple, je gère la traduction sur ce site avec le chemin de l'url; regardez la barre d'adresse: l'article que vous êtes en train de lire actuellement a un nom de domaine `blog.simontirant.dev` / puis la route `post` / puis l'id de l'article (`custom_http_codes`) / enfin l'attribut de langue qui peut être soit `french` soit `english`. Si vous décidez - pour quelque raison que ce soit - de changer ce dernier attribut du chemin pour écrire `silbo` à la place (n.b.: le *silbo* est une antique langue sifflée utilisée à Gomera, une des îles Canaries), alors le serveur lèvera cette exception `404 Not Found` - à la place de la `500` par défaut - car, bien que je puisse toujours apprendre le silbo en ligne et enregistrer mon article tech dans un fichier audio pour que vous puissiez l'écouter dans un lecteur web, je ne suis pas sûr qu'il y ait un public pour ça.

Concrètement, ma fonction `show/2` située dans mon `BlogController` appelle une autre fonction, située dans le module `Blog`, nommée `get_post_by_id_and_lang!/2`, en lui passant comme paramètres les attributs d'url concernant la langue et l'id de l'article. Cette fonction `Blog.get_post_by_id_and_lang!/2` est ensuite chargée de retrouver l'article par son id et sa langue (car deux articles peuvent avoir le même id s'ils sont dans une langue différente), si `nil` elle lève une exception appelée `NotFoundError` qui a été auparavant déclarée dans son propre module. Voici un extrait de mon code ci-dessous: 

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

*P.S.: ce blog utilise la librairie [NimblePublisher](https://hex.pm/packages/nimble_publisher) pour rendre des articles de blog à partir de fichiers [Markdown](https://daringfireball.net/projects/markdown/) situés dans un fichier du serveur. Comme je n'utilise pas de base de données, il n'y a donc pas de fonctions [Ecto](https://hexdocs.pm/ecto/Ecto.html) telles que `Repo.get!/3`, mais des fonctions venant du module `Enum` à la place. [Lisez la première partie de mon article sur NimblePublisher ici](https://blog.simontirant.dev/post/nimble_blog_1/french).*

Comme nous pouvons le voir, l'exception déclarée comme `NotFoundError` est liée à un [code HTTP](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status) `404` classique, ceci grâce à l'option `plug_status: 404` que j'ai ajouté juste après `:message` dans la déclaration de mon exception. La `404` est un [code HTTP](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status) bien connu et [Plug](https://hexdocs.pm/plug/readme.html) la connait déjà, regardez au tout début du module `Plug.Conn.Status`, situé dans le dossier des `deps`:

```elixir
  statuses = %{
    ...,
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

Cela signifie que si ma fonction échoue à retrouver un article de blog pour cet id et cette langue - sous-entendant qu'au moins un des deux arguments de l'url, situés après la route `post`, est faux - alors l' exception `NotFoundError` est levée, appelant l'erreur `404` de [Plug](https://hexdocs.pm/plug/readme.html), puis [Phoenix](https://www.phoenixframework.org/) redirige le visiteur vers la page `404.html.heex` que j'ai créé à l'intérieur de mon dossier `error_html`, lui-même situé dans le dossier des `controllers`. Pour appeler ce _template_ en particulier, il faut se rendre dans la vue `error_html.ex` (toujours dans le dossiers des `controllers`) et ajouter `embed_templates("error_html/*")` - à la place de la fonction `render/2` déjà présente. Avec ceci, [Phoenix](https://www.phoenixframework.org/) pourra afficher les templates du dossier `error_html` pour vos pages d'erreur personnalisées ([lien vers la page dédiée de la documentation](https://hexdocs.pm/phoenix/1.7.7/custom_error_pages.html)).

Ce mécanisme consistant à appeler le status `404` de [Plug](https://hexdocs.pm/plug/readme.html) depuis une exception, [Phoenix](https://www.phoenixframework.org/) le fait lui aussi pour une `NoRouteError` - une exception nativement levée par le module `Phoenix.Router` quant une route simple n'existe tout simplement pas: par exemple, si vous écrivez `/pist` au lieu de `/post` dans l'url. Dans notre cas, la langue et l'id étant des paramètres et non pas une route, un terme incorrect sur ceux-ci aurait nativement appelé l'erreur `500` et non pas `404`; mais j'aurais donc tout aussi bien pu décider d'importer et de lever dans mon module `Blog`  l'exception native `Phoenix.Router.NotFoundError`, au lieu de créer ma propre exception, car elle appelle aussi le status `404` de [Plug](https://hexdocs.pm/plug/readme.html). 

Mais si vous avez réellement regardé, comme je l'ai demandé, en haut du module `Plug.Conn.Status` de n'importe quelle projet [Phoenix](https://www.phoenixframework.org/), vous devez avoir vu ceci juste avant la liste des status HTTP : 

```elixir
  custom_statuses = Application.compile_env(:plug, :statuses, %{})
```

Vous savez ce que ça veut dire ? Ça veut dire que, même si la [liste des codes HTTP](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status) a déjà anticipé des blagues à l'intention des développeurs - telles que `418 I'm a teapot` ou, ma préférée, `451 Unavailable For Legal Reasons` ... la censure d'état dans _Fahrenheit 451_, vous l'avez ? - afin qu'ils puissient rigoler un peu, elle laisse tout un tas de codes disponibles afin de créer vos propres status bizarres.

### Prêt à jouer avec les nombres ? 🧮

Donc, j'ai aussi besoin de lever une erreur quand le résultat d'un filtre par tags dans une langue en particulier est vide. Ainsi, si vous cliquez, par exemple, sur le tag `tricot 🧶` puis sur le drapeau `anglais 🇬🇧` pour filtrer uniquement les articles en anglais sur le tricot, et bien vous allez lever mon [code HTTP]((https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)) personnalisé `461 No Blog Posts Found` ... Car je n'ai pas encore écrit d'article en anglais sur le sujet. Et parce qu'il s'agit ici d'un blog tech, l'exception aurait été levée en `français 🇫🇷` aussi ! Ce status, comme le `404`, va ensuite appeler la vue `461.html.heex` située dans le dossier `error_html` pour vous expliquer que le serveur n'a trouvé aucun article pour votre requête. 

Mais ... Comment ai-je fait ceci ? Est-ce de la **magie noire** ? *Boooo...*🕷️🔮🪄🧿

Et bien, en vérité non. Je l'ai juste fait en utilisant la fonction `Config.config/3` sur les status de [Plug](https://hexdocs.pm/plug/readme.html) à l'intérieur du fichier `config.exs` dans le répertoire `config`:

```elixir
import Config

config :plug, :statuses, %{461 => "No Blog Posts Found"}
```

De cette façon, lors de la compilation, [Plug](https://hexdocs.pm/plug/readme.html) va construitre sa map de `status` que nous avons vue plus tôt avec le [code HTTP](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status) `404`, **mais en incluant cette fois-ci** les status personnalisés que nous avons passé dans le fichier `config.exs`. Comme vous l'aurez peut-être compris, il est nécessaire de recompiler la dépendance [Plug](https://hexdocs.pm/plug/readme.html) après cette modification et, dans mon cas, j'ai dû utiliser `mix deps.compile plug --force`, sans quoi `mix` retournait une erreur si je n'ajoutais pas l'option `--force`. Après cela, je peux ensuite faire ce qui suit dans mon module `Blog` afin de filtrer les articles de blog:

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

Comme pour le code `404`, j'ai déclaré mon exception `NoBlogPostsError` à l'intérieur de son propre module et j'ai utilisé cette fois-ci l'option `plug_status: 461` afin d'appeler le status personalisé que nous avons paramétré auparavant dans `config.exs`. Les fonctions en charge de retourner la liste des `%Post{}` - filtrée par langue, par tag ou les deux - peuvent ensuite lever le module d'exception `NoBlogPostsError` dans le cas où la liste des `%Post{}` serait vide.

*N.B.: cette méthode, pour ajouter des codes personnalisés à partir de ceux qui ne sont pas utilisés par la [liste des codes HTTP](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status) standard, peut aussi être utilisée pour créer un message de status différent pour un code existant déjà. Ainsi, vous pouvez modifier le `404 Not Found` pour un effronté `404 Found But Don't Want To Show It To You`; ou encore `451 Sorry But It Burned!`. Super!* 