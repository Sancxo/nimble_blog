defmodule NimbleBlogWeb.BlogHTML do
  use NimbleBlogWeb, :html
  use Phoenix.HTML

  alias NimbleBlog.Blog

  embed_templates "blog_html/*"
end
