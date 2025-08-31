defmodule NimbleBlogWeb.ActivityPubController do
  use NimbleBlogWeb, :controller

  def webfinger(conn, _) do
    send_download(conn, {:binary, %{
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
        ]
    } |> Jason.encode!()}, filename: "webfinger")
  end
end
