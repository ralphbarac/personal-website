defmodule Website.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :body, :string
    field :slug, :string
    field :image_path, :string
    field :read_time, :integer, default: 0
    field :description, :string

    belongs_to :category, Website.Blog.Category

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :slug, :description, :image_path, :read_time, :category_id])
    |> validate_required([:title, :body, :slug, :description, :image_path, :category_id])
    |> unique_constraint(:slug)
    |> calculate_read_time()
  end

    # TODO: This could be refactored into a more general helper for strings/times.
    def format_read_time(%__MODULE__{read_time: minutes}) when is_integer(minutes) do
      if minutes == 1 do
        "1 minute"
      else
        "#{minutes} minutes"
      end
    end

  defp calculate_read_time(changeset) do
    body = get_field(changeset, :body) || ""
    word_count = String.split(body) |> length()
    read_time = div(word_count, 200) + if rem(word_count, 200) > 0, do: 1, else: 0

    put_change(changeset, :read_time, read_time)
  end
end
