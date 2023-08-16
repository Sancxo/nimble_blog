defmodule NimbleBlogWeb.ErrorHTML do
  use NimbleBlogWeb, :html

  @moduledoc """
  It is worth noting that we did not render our error page templates
  through our application layout, even though we want our error page to
  have the look and feel of the rest of our site. This is to avoid circular
  errors. For example, what happens if our application failed due to an
  error in the layout? Attempting to render the layout again will just trigger
  another error. So ideally we want to minimize the amount of dependencies and
  logic in our error templates, sharing only what is necessary.
  """

  # If you want to customize your error pages,
  # uncomment the embed_templates/1 call below
  # and add pages to the error directory:
  #
  #   * lib/nimble_blog_web/controllers/error_html/404.html.heex
  #   * lib/nimble_blog_web/controllers/error_html/500.html.heex
  #
  # embed_templates "error_html/*"

  # The default is to render a plain text page based on
  # the template name. For example, "404.html" becomes
  # "Not Found".

  # def render(template, _assigns) do
  #   Phoenix.Controller.status_message_from_template(template)
  # end

  embed_templates("error_html/*")
end
