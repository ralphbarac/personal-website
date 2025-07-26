defmodule Website.Blog do
  @moduledoc """
  The Blog context.

  This context handles all blog-related functionality including posts and categories.
  It provides a unified interface for blog operations with proper query optimization
  and preloading strategies.
  """

  import Ecto.Query, warn: false
  alias Website.Repo
  alias Website.Blog.{Post, Category}

  # Post functions

  @doc """
  Returns the list of all posts with preloaded categories.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Post
    |> order_by([p], desc: p.inserted_at)
    |> preload(:category)
    |> Repo.all()
  end

  @doc """
  Returns the list of published posts with preloaded categories.

  ## Examples

      iex> list_published_posts()
      [%Post{}, ...]

  """
  def list_published_posts do
    Post
    |> where([p], p.status == :published)
    |> order_by([p], desc: p.inserted_at)
    |> preload(:category)
    |> Repo.all()
  end

  @doc """
  Returns published posts filtered by category with preloaded associations.

  ## Examples

      iex> list_published_posts_by_category(1)
      [%Post{}, ...]

  """
  def list_published_posts_by_category(category_id) do
    Post
    |> where([p], p.status == :published and p.category_id == ^category_id)
    |> order_by([p], desc: p.inserted_at)
    |> preload(:category)
    |> Repo.all()
  end

  @doc """
  Returns published posts for RSS feed with limit and preloaded associations.

  ## Examples

      iex> list_published_posts_for_rss(10)
      [%Post{}, ...]

  """
  def list_published_posts_for_rss(limit \\ 20) do
    Post
    |> where([p], p.status == :published)
    |> order_by([p], desc: p.inserted_at)
    |> limit(^limit)
    |> preload(:category)
    |> Repo.all()
  end

  @doc """
  Returns posts for admin interface with optional filtering and preloaded associations.

  ## Options

    * `:title` - Filter by title (case-insensitive partial match)
    * `:category_id` - Filter by category ID
    * `:status` - Filter by status (:draft or :published)

  ## Examples

      iex> list_posts_admin(%{status: :published})
      [%Post{}, ...]

  """
  def list_posts_admin(filters \\ %{}) do
    Post
    |> order_by([p], desc: p.inserted_at)
    |> apply_post_filters(filters)
    |> preload(:category)
    |> Repo.all()
  end

  @doc """
  Gets a single post by ID with preloaded category.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    Post
    |> preload(:category)
    |> Repo.get!(id)
  end

  @doc """
  Gets a published post by slug with preloaded category.

  Raises `Ecto.NoResultsError` if the Post does not exist or is not published.

  ## Examples

      iex> get_published_post_by_slug!("hello-world")
      %Post{}

      iex> get_published_post_by_slug!("nonexistent")
      ** (Ecto.NoResultsError)

  """
  def get_published_post_by_slug!(slug) do
    Post
    |> where([p], p.slug == ^slug and p.status == :published)
    |> preload(:category)
    |> Repo.one!()
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{title: "Hello World", body: "Content"})
      {:ok, %Post{}}

      iex> create_post(%{title: ""})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{title: "New Title"})
      {:ok, %Post{}}

      iex> update_post(post, %{title: ""})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  @doc """
  Toggles the status of a post between :draft and :published.

  ## Examples

      iex> toggle_post_status(post)
      {:ok, %Post{}}

  """
  def toggle_post_status(%Post{} = post) do
    new_status = if post.status == :published, do: :draft, else: :published
    update_post(post, %{status: new_status})
  end

  @doc """
  Returns the count of published posts.

  ## Examples

      iex> count_published_posts()
      42

  """
  def count_published_posts do
    Post
    |> where([p], p.status == :published)
    |> Repo.aggregate(:count, :id)
  end

  # Category functions

  @doc """
  Returns the list of categories ordered by name.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Category
    |> order_by([c], c.name)
    |> Repo.all()
  end

  @doc """
  Returns categories with post counts for admin interface.

  ## Examples

      iex> list_categories_with_post_counts()
      [%{category: %Category{}, post_count: 5}, ...]

  """
  def list_categories_with_post_counts do
    Category
    |> join(:left, [c], p in assoc(c, :posts))
    |> group_by([c], c.id)
    |> select([c, p], %{
      category: c,
      post_count: count(p.id),
      published_count: count(p.id, :distinct) |> filter(p.status == :published)
    })
    |> order_by([c], c.name)
    |> Repo.all()
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id) do
    Repo.get!(Category, id)
  end

  @doc """
  Gets a category by slug.

  ## Examples

      iex> get_category_by_slug("tech")
      %Category{}

      iex> get_category_by_slug("nonexistent")
      nil

  """
  def get_category_by_slug(slug) do
    Repo.get_by(Category, slug: slug)
  end

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{name: "Tech"})
      {:ok, %Category{}}

      iex> create_category(%{name: ""})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{name: "New Name"})
      {:ok, %Category{}}

      iex> update_category(category, %{name: ""})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category if it has no associated posts.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category_with_posts)
      {:error, :has_posts}

  """
  def delete_category(%Category{} = category) do
    case has_posts?(category.id) do
      true -> {:error, :has_posts}
      false -> Repo.delete(category)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  # Private functions

  defp apply_post_filters(query, filters) do
    query
    |> filter_by_title(Map.get(filters, :title))
    |> filter_by_category(Map.get(filters, :category_id))
    |> filter_by_status(Map.get(filters, :status))
  end

  defp filter_by_title(query, nil), do: query
  defp filter_by_title(query, ""), do: query

  defp filter_by_title(query, title) do
    from(p in query, where: ilike(p.title, ^"%#{title}%"))
  end

  defp filter_by_category(query, nil), do: query

  defp filter_by_category(query, category_id) when is_integer(category_id) do
    from(p in query, where: p.category_id == ^category_id)
  end

  defp filter_by_category(query, _), do: query

  defp filter_by_status(query, nil), do: query

  defp filter_by_status(query, status) when status in [:draft, :published] do
    from(p in query, where: p.status == ^status)
  end

  defp filter_by_status(query, _), do: query

  defp has_posts?(category_id) do
    Post
    |> where([p], p.category_id == ^category_id)
    |> Repo.aggregate(:count, :id) > 0
  end
end
