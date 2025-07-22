defmodule Website.Gallery do
  @moduledoc """
  The Gallery context handles photo-related queries and business logic.
  """

  import Ecto.Query
  alias Website.Repo
  alias Website.Photo

  @doc """
  Fetches photos filtered by the given category. If "All" is passed, it returns all photos.
  """
  def fetch_photos(), do: Repo.all(Photo)

  def fetch_photos_by_category(category) do
    Photo
    |> where(category: ^category)
    |> Repo.all()
  end
end
