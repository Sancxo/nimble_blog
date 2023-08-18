%{
  title: "Nimble Blog (1/2)",
  author: "Simon Tirant",
  tags: ~w(elixir phoenix web blog nimblepublisher),
  lang: "en",
  description: "Yes, blogs are has been ; so it's time to make a new one ! Here, before we get our hands dirty, we gonna see the purpose of NimblePublisher: a light Elixir library to make a quick and fast dynamic blog with Phoenix.",
  illustration: "/images/posts/printing.webp",
  illustration_alt: "Magicien disparaissant dans un nuage de fumée"
}
---

### Genesis of a library 📖

Three years from now (i.e. in 2020), [José Valim](https://www.linkedin.com/in/josevalim/), the creator of **Elixir**, [published an article on Dashbit's blog](https://dashbit.co/blog/welcome-to-our-blog-how-it-was-made) about the new way they decided to conceive their own blog. As it is mostly a website with static content, they would not struggle with a heavy CMS as [WordPress](https://wordpress.org/) or others (is there any '_others_' than WordPress actually❓❓❓).

You also have static site generators, as the well-known [Jekyll](https://jekyllrb.com/), to transform your [Markdown](https://daringfireball.net/projects/markdown/) files [Git](https://git-scm.com/) repository into a beautiful HTML page. Meaning: you write, you `git add .`, you `git commit -m "My awesome new post"`, you `git push` and **voilà** ! It's published ! But as you have to build your page upstream, there is absolutely no dynamic content. Not even a little. In concrete terms, it means that ***you can't filter, sort or paginate your articles*** as you would expect in a nice blog like the one you are currently reading (isn't it ? No ? Please say '*Yes*' 🥺🙏).

So the 1 billion dollar question (actually it's free because it's open source) is: '***How lord can I get the best of two worlds ? How can I have a sligthly dynamic blog compiled from simple Markdown files located on a dedicated Git repository??? Please tell me! TELL ME!***'

Keep calm John-John, **José has your back!** Indeed, first of all, the previously mentioned article continues to describe the way they did a dynamic blog using [Phoenix](https://www.phoenixframework.org/) to pre-compile and load into memory their Markdown posts located inside a framework folder (meaning in disk **and not in database**!).

> In a nutshell, when our project compiles, we read all blog posts from disk and convert them into in-memory data structures.
>
> José Valim

The article goes deep into code so you can see all the definition of the `%Post{}` struct, the function to call all the `.md` files in order to transform them into a `%Post{}` list, sorted by descending publication date, and stored inside a module attribute (the `@` operator). This module attribute can then be called through a public function called `list_posts/0`, serving **at runtime** the content stored in memory **during compile-time**.

Well, here it is, in front of your eyes, the 17 lines of code which sum up the heart of the blog app:

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

Then, more than a tutorial article, José decided to turn these lines of code into a Hex library named **[NimblePublisher](https://hex.pm/packages/nimble_publisher)**. Now you can do the same as Dashbit without taking care of parsing the Markdown files into structs (except if you want to customize the parsing) or converting the Markdown syntax into plain old HTML at compile-time (which is actually done by [Earmark](https://hex.pm/packages/earmark) and [MakeupElixir](https://hex.pm/packages/makeup_elixir) dependencies).

And that's exactly what we'll see in the next article: a tutorial about NimblePublisher powered by Phoenix 1.7, the latest version of the framework which brings changes to the views mechanism!
