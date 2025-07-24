defmodule Website.Blog.Posts do
  import Ecto.Query
  alias Website.Blog.Post
  alias Website.Repo

  def list_posts do
    Repo.all(Post)
    |> Repo.preload(:category)
  end

  def list_published_posts do
    from(p in Post, where: p.status == "published", order_by: [desc: p.inserted_at])
    |> Repo.all()
    |> Repo.preload(:category)
  end

  def list_published_posts_by_category(category_id) do
    from(p in Post, 
      where: p.status == "published" and p.category_id == ^category_id, 
      order_by: [desc: p.inserted_at]
    )
    |> Repo.all()
    |> Repo.preload(:category)
  end

  def list_published_posts_for_rss(limit \\ 20) do
    from(p in Post, 
      where: p.status == "published", 
      order_by: [desc: p.inserted_at],
      limit: ^limit
    )
    |> Repo.all()
    |> Repo.preload(:category)
  end

  def list_posts_admin(filters \\ %{}) do
    query = from(p in Post, order_by: [desc: p.inserted_at])

    query
    |> filter_by_title(filters[:title])
    |> filter_by_category(filters[:category_id])
    |> filter_by_status(filters[:status])
    |> Repo.all()
    |> Repo.preload(:category)
  end

  def get_post!(id) do
    Repo.get!(Post, id)
    |> Repo.preload(:category)
  end

  def get_post_by_slug!(slug) do
    from(p in Post, where: p.slug == ^slug and p.status == "published")
    |> Repo.one!()
    |> Repo.preload(:category)
  end

  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def toggle_post_status(%Post{} = post) do
    new_status = if post.status == "published", do: "draft", else: "published"
    update_post(post, %{status: new_status})
  end

  defp filter_by_title(query, nil), do: query
  defp filter_by_title(query, ""), do: query
  defp filter_by_title(query, title) do
    from(p in query, where: ilike(p.title, ^"%#{title}%"))
  end

  defp filter_by_category(query, nil), do: query
  defp filter_by_category(query, ""), do: query
  defp filter_by_category(query, category_id) do
    from(p in query, where: p.category_id == ^category_id)
  end

  defp filter_by_status(query, nil), do: query
  defp filter_by_status(query, ""), do: query
  defp filter_by_status(query, status) do
    from(p in query, where: p.status == ^status)
  end
end
