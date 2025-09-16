defmodule NimbleBlogWeb.ActivityPubController do
  use NimbleBlogWeb, :controller

  def webfinger(conn, _) do
    render(conn, :webfinger)
  end

  def actor(conn, _) do
    conn |> IO.inspect(label: "conn")

    render(conn, :actor)
  end
end
