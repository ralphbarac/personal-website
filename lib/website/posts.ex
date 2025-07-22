defmodule Website.Blog.Posts do
  alias Website.Blog.Post
  alias Website.Repo

  def list_posts do
    Repo.all(Post)
    |> Repo.preload(:category)
  end

  def get_post!(id) do
    Repo.get!(Post, id)
    |> Repo.preload(:category)
  end
end
