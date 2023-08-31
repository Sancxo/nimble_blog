%{
  title: "Nimble Blog (1/2)",
  author: "Simon Tirant",
  tags: ~w(elixir phoenix web blog nimblepublisher),
  lang: "fr",
  description: "Oui, les blogs sont has-been ; alors c'est le moment d'en créer un ! Ici, avant de nous salir les mains, nous allons voir quel est l'intérêt de NimblePublisher: une librairie Elixir très légère pour créer un blog rapide et dynamique avec Phoenix.",
  illustration: "/images/posts/printing.webp",
  illustration_alt: "Impression industrielle de journaux en activité"
}
---

### La génèse d'une librarie 📖

Il y a trois ans de cela (c-à-d. en 2020), [José Valim](https://www.linkedin.com/in/josevalim/), le créateur d'**Elixir**, [a publié un article sur le blog de Dashbit](https://dashbit.co/blog/welcome-to-our-blog-how-it-was-made) racontant la nouvelle façon avec laquelle ils ont décidé de concevoir leur nouveau blog. Comme c'est pricnipalement un site avec du contenu statique, ils ne voulaient pas s'embêter avec un CMS lourd comme [WordPress](https://wordpress.org/) ou autres (existe-t-il vraiment d'*autres* que Wordpress en réalité ❓❓❓).

Vous avez aussi les générateurs de sites statiques, tels que le très réputé [Jekyll](https://jekyllrb.com/), pour transformer vos repos [Git](https://git-scm.com/) de fichiers [Markdown](https://daringfireball.net/projects/markdown/) en une belle page HTML. Signification: vous écrivez, vous `git add .`, vous `git commit -m "Mon super nouveau post"`, vous `git push` et **voilà** ! C'est publié ! Mais vous devez aussi construire votre page en amont, donc il n'y a absolument aucun contenu dynamic. Même pas un tout petit peu. Concrètement, cela veut dire que ***vous ne pouvez ni filtrer, ni trier, ni paginer vos articles*** comme vous pourriez l'attendre d'un super blog tel que celui que vous êtes actuellement en train de lire (n'est-ce pas ? S'il vous plaît, dites "*Oui*" 🥺🙏).

Alors, la question à 1 million de dollars (en vrai c'est gratuit car c'est *open source*) est : "***Seigneur, comment puis-je obtenir le meilleur des deux mondes ? Comment puis-je avoir un blog légèrement dynamique compilé à partir de simple fichiers Markdown situés sur un repertoir Git dédié ??? S'il te plaît, aide-moi ! AIDE-MOI !***"

Calme-toi Jean-Jean, **José t'assure le coup !** En effet, pour commencer, l'article précédemment mentionné continue de décrire la façon dont ils ont fait un blog dynamique, en utilisant [Phoenix](https://www.phoenixframework.org/) pour pré-compiler et charger en mémoire leurs posts Markdown situés à l'intérieur d'un fichier du framework (à savoir sur le disque **et non pas en base de données**!).

> En un mot, quand ton projet compile, nous lisons tous les posts de blog depuis le disque et nous les convertissons en des structures de données en mémoire.
>
> José Valim (traduit depuis l'anglais)

L'article va assez profondément dans le code afin que vous puissiez tout voir: la définition de la struct `%Post{}`, la fonction pour appeler les fichiers `.md` afin de les transformer en une liste de `%Post{}`, triée par date de publication descendante et stockée à l'intérieur d'un *module attribute* (l'opérateur `@)`). Ce module peut ensuite être appelé via une fonction publique nommée `list_post/0`, servant lors **de l'éxécution** le contenu stocké en mémoire **durant la compilation**.

Et bien voici, juste devant vos beaux yeux, les 17 lignes de code qui résument à elles-seules le coeur de leur application de blog :

```elixir
  defmodule Dashbit.Blog do
    alias Dashbit.Blog.Post

    posts_paths = "posts/**/*.md" |> Path.wildcard() |> Enum.sort()

    posts =
      for post_path <- posts_paths do
        @external_resource Path.relative_to_cwd(post_path)
        Post.parse!(post_path)
      end

    @posts Enum.sort_by(posts, & &1.date, {:desc, Date})

    def list_posts do
      @posts
    end
  end
```

Ensuite, plus qu'un simple article tutoriel, José a décidé de faire de ces lignes de codes une librairie Hex nommée **[NimblePublisher](https://hex.pm/packages/nimble_publisher)**. Maintenant vous pouvez faire pareil que Dashbit sans avoir à analyser les fichiers Markdown en des structs (sauf si vous voulez personaliser l'analyse) ou convertir la syntaxe Markdown en un bon vieux HTML lors de la compilation (ce qui est en réalité fait par les dépendances [Earmark](https://hex.pm/packages/earmark) et [MakeupElixir](https://hex.pm/packages/makeup_elixir)).

Et c'est exactement ce que nous allons voir dans le prochain article: un tutoriel sur NimblePublisher propulsé par Phoenix 1.7, la dernière version du *framework* qui ammène des changements dans le mécanisme des vues!