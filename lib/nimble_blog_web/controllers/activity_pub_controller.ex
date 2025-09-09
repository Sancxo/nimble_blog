defmodule NimbleBlogWeb.ActivityPubController do
  use NimbleBlogWeb, :controller

  def webfinger(conn, _) do
    send_download(
      conn,
      {:binary,
       %{
         subject: "acct:@blog@blog.simontirant.dev",
         aliases: [
           "https://blog.simontirant.dev/@blog"
         ],
         links: [
           %{
             rel: "self",
             type: "application/activity+json",
             href: "https://blog.simontirant.dev/@blog"
           }
           #  %{
           #    rel: "http://webfinger.net/rel/profile-page",
           #    type: "text/html",
           #    href: "https://blog.simontirant.dev/"
           #  }
         ]
       }
       |> Jason.encode!()},
      filename: "webfinger"
    )
  end

  def actor(conn, _) do
    send_download(
      conn,
      {:binary,
       %{
         "@context": "https://www.w3.org/ns/activitystreams",
         id: "https://blog.simontirant.dev/@blog",
         type: "Person",
         following: "https://mastodon.social/@sancxo/following",
         followers: "https://mastodon.social/@sancxo/followers",
         inbox: "https://blog.simontirant.dev/socialweb/inbox",
         outbox: "https://blog.simontirant.dev/socialweb/outbox",
         preferredUsername: "blog",
         name: "Simon Tirant's blog",
         summary: "Some Elixir language tech articles, mostly in french.",
         url: "https://blog.simontirant.dev",
         discoverable: true,
         memorial: false,
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
           "@context": "https://w3id.org/security/v1",
           "@type": "Key",
           id: "https://blog.simontirant.dev/@blog#main-key",
           owner: "https://blog.simontirant.dev/@blog",
           publicKeyPem:
             "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA68oSTjzLryZ+lLIu8N5+\nCZdQPKaN6xZCY93uzJ8b4wjOecEykQcGU2J+ejOzMXHP4o4N+Rc0xnxyAs9ZN5AX\ndYSObpdfGQvrvdHanu+iTyRKETKMbSHtJzk5dZW8l+pPnX2YWKVgSfCG2SALZprg\nzxyhbtTLq8JoN8b5TgEA1B12Rya3aBNNXDT1/eeU+/HqwtKN2nLAdvACbccPAtg1\nVeKdcSgmS2o51JR4MjJWcCgM2HrAZUepF1XM59Yeq136QGviJpfAFX6gS7POvi7r\n3iaH0GzuUzR+WJSHgoJ65VzC9wy4Vpw/jt8CNtlW13iFRasHARTwFe+1FhuZayPG\neQIDAQAB\n-----END PUBLIC KEY-----"
         },
         attachement: [
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
       |> Jason.encode!()},
      filename: "actor"
    )
  end
end
