defmodule NimbleBlogWeb.Layouts do
  use NimbleBlogWeb, :html

  embed_templates "layouts/*"

  def go_up_arrow(assigns) do
    ~H"""
    <img
      src="/images/arrow_up.png"
      alt="Go up arrow"
      id="go-up-arrow"
      onclick="window.scrollTo({top: 0, behavior: 'smooth'})"
    />
    """
  end
end
