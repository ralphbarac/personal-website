defmodule Website.Blog.Categories do
  import Ecto.Query
  alias Website.Blog.{Category, Post}
  alias Website.Repo

  def list_categories do
    # For now, just return basic categories - we can enhance with post counts later if needed
    from(c in Category, order_by: c.name)
    |> Repo.all()
  end

  def get_category!(id) do
    Repo.get!(Category, id)
  end

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category) do
    case has_posts?(category.id) do
      true -> {:error, :has_posts}
      false -> Repo.delete(category)
    end
  end

  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  defp has_posts?(category_id) do
    query = from(p in Post, where: p.category_id == ^category_id, select: count(p.id))
    Repo.one(query) > 0
  end
end