defmodule NimbleBlogWeb.ActivityPubJSON do
  def webfinger(_) do
    %{
      subject: "acct:blog@blog.simontirant.dev",
      aliases: [
        "https://blog.simontirant.dev/@blog"
      ],
      links: [
        %{
          rel: "self",
          type: "application/activity+json",
          href: "https://blog.simontirant.dev/@blog"
        },
        %{
          rel: "https://webfinger.net/rel/profile-page",
          type: "text/html",
          href: "https://blog.simontirant.dev/"
        }
      ]
    }
  end

  def actor(_) do
    %{
      "@context": [
        "https://www.w3.org/ns/activitystreams",
        "https://w3id.org/security/v1"
      ],
      id: "https://blog.simontirant.dev/@blog",
      type: "Person",
      following: "https://mastodon.social/users/sancxo/following",
      followers: "https://mastodon.social/users/sancxo/followers",
      inbox: "https://blog.simontirant.dev/socialweb/inbox",
      outbox: "https://blog.simontirant.dev/socialweb/outbox",
      preferredUsername: "blog",
      name: "Simon Tirant's blog",
      summary: "Some Elixir language tech articles, mostly in french.",
      url: "https://blog.simontirant.dev",
      discoverable: true,
      indexable: true,
      manuallyApprovesFollowers: false,
      memorial: false,
      published: "2025-08-17T00:00:00Z",
      icon: %{
        type: "Image",
        mediaType: "image/png",
        url: "https://simontirant.dev/apple-touch-icon.png"
      },
      image: %{
        type: "Image",
        mediaType: "image/jpg",
        url: "https://simontirant.dev/static/media/simon_tirant_img.0b14a05ffa9736bd7d1b.JPG"
      },
      publicKey: %{
        id: "https://blog.simontirant.dev/@blog#main-key",
        owner: "https://blog.simontirant.dev/@blog",
        publicKeyPem: """
        -----BEGIN PUBLIC KEY-----
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwx9WX3qvmX8m+SrtaEnV
        WJFYiurnh3GpAGD+Luzlm/H/pKM7dY9XigWXkJtUhLS/w7ucEdejaFoQYYAg4BL9
        lMEZPOljp7CBhO0Qgn6DTxolaCQhCfD0+W751Gr5uA+RGzRgtk6wf2oUChVE5nN6
        3H/YiqqfgDAFwV9giq7KxbfeCdSXWpt/MUqbI0mkAxWzp5kHAhpu0fsmo/Alktku
        XD48sRIcWTuZVb6l3qvTdHxVsFvtLA+NWUcKbRtc79l/mPhBVeiXeq9/qxvD8+qp
        E5RArkoAAGfY//MW7a6BAWx5mre3L2Z35mTvNXQ9x+JroKKtgRIVzRDZ3JM+l4rb
        FQIDAQAB
        -----END PUBLIC KEY-----
        """
      },
      attachment: [
        %{
          type: "PropertyValue",
          name: "Blog",
          value:
            "<a href=\"https://simontirant.dev\" target=\"_blank\" rel=\"nofollow noopener noreferrer me\" translate=\"no\">https://simontirant.dev</a>"
        },
        %{
          type: "PropertyValue",
          name: "LinkedIn",
          value:
            "<a href=\"https://www.linkedin.com/in/simontirant\" target=\"_blank\" rel=\"nofollow noopener noreferrer me\" translate=\"no\">https://www.linkedin.com/in/simontirant</a>"
        },
        %{
          type: "PropertyValue",
          name: "GitHub",
          value:
            "<a href=\"https://github.com/Sancxo\" target=\"_blank\" rel=\"nofollow noopener noreferrer me\" translate=\"no\">https://github.com/Sancxo</a>"
        }
      ]
    }
  end

  def outbox(_) do
    %{
      "@context": "https://www.w3.org/ns/activitystreams",
      id: "https://blog.simontirant.dev/socialweb/outbox",
      type: "OrderedCollection",
      summary: "Some Elixir language tech articles, mostly in french.",
      totalItems: NimbleBlog.Blog.count_all_unique_posts(),
      orderedItems: NimbleBlog.Blog.all_posts() |> Enum.dedup_by(& &1.id) |> Enum.map(& jsonify_article(&1))
    }
  end

  defp jsonify_article(article) do
    %{
      "@context": "https://www.w3.org/ns/activitystreams",
      id: "https://blog.simontirant.dev/#{article.id}",
      type: "Note",
      content: article.body,
      url: "https://blog.simontirant.dev/#{article.id}",
      attributedTo: "https://blog.simontirant.dev/@blog",
      to: ["https://www.w3.org/ns/activitystreams#Public"],
      cc: [],
      published: article.date,
      tag: get_tags(article.tags),
      replies: %{}
    }
  end

  defp get_tags(tags) do
    tag_list =
      Enum.map(tags, fn tag ->
        %{
          Type: "Hashtag",
          Href: "https://blog.simontirant.dev/tags/#{tag}",
          Name: "##{tag}"
        }
      end)

    mention_tag = %{
      Type: "Mention",
      Href: "https://mastodon.social/users/sancxo",
      Name: "@sancxo@mastodon.social"
    }

    [mention_tag | tag_list]
  end
end
