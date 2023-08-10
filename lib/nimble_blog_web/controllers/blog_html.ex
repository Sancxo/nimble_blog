defmodule NimbleBlogWeb.BlogHTML do
  use NimbleBlogWeb, :html
  use Phoenix.HTML

  embed_templates "blog_html/*"
end
