defmodule NimbleBlog.Blog.Post do
  @enforce_keys [
    :id,
    :author,
    :title,
    :body,
    :illustration,
    :description,
    :tags,
    :date,
    :lang
  ]
  defstruct [
    :id,
    :author,
    :title,
    :body,
    :illustration,
    :illustration_alt,
    :description,
    :tags,
    :date,
    :lang
  ]

  def build(filename, attrs, body) do
    [year, month_day_id] = filename |> Path.rootname() |> Path.split() |> Enum.take(-2)
    [month, day, id] = String.split(month_day_id, "-", parts: 3)
    date = Date.from_iso8601!("#{year}-#{month}-#{day}")
    struct!(__MODULE__, [id: id, date: date, body: body] ++ Map.to_list(attrs))
  end
end
