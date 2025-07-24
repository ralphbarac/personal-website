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
    field :status, :string, default: "draft"

    belongs_to :category, Website.Blog.Category

    timestamps(type: :utc_datetime)
  end

  @valid_statuses ~w(draft published)

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :slug, :description, :image_path, :read_time, :category_id, :status])
    |> validate_required([:title, :body, :description, :category_id])
    |> validate_inclusion(:status, @valid_statuses)
    |> generate_slug()
    |> validate_required([:slug])
    |> unique_constraint(:slug)
    |> calculate_read_time()
    |> validate_image_path()
  end

  defp validate_image_path(changeset) do
    # Ensure that either image_path is provided or it's an update (existing record has one)
    case {get_field(changeset, :image_path), changeset.data.id} do
      {nil, nil} -> add_error(changeset, :image_path, "must be provided for new posts")
      _ -> changeset
    end
  end

  defp generate_slug(changeset) do
    case get_field(changeset, :slug) do
      nil ->
        title = get_field(changeset, :title)
        if title do
          slug = title |> String.downcase() |> String.replace(~r/[^\w\s]/, "") |> String.replace(~r/\s+/, "-")
          put_change(changeset, :slug, slug)
        else
          changeset
        end
      _ ->
        changeset
    end
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
