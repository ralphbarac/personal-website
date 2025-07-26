defmodule Website.BlogTest do
  use Website.DataCase

  alias Website.Blog.Post

  describe "read time calculation" do
    test "calculates read time correctly for different word counts" do
      category = insert(:category)

      # Test short content (< 200 words = 1 minute)
      short_post = %{
        title: "Short",
        # 50 words
        body: String.duplicate("word ", 50),
        slug: "short",
        description: "Short",
        image_path: "/test.jpg",
        category_id: category.id
      }

      changeset = Post.changeset(%Post{}, short_post)
      assert Ecto.Changeset.get_change(changeset, :read_time) == 1

      # Test long content (400 words = 2 minutes)
      long_post = %{
        title: "Long",
        # 400 words
        body: String.duplicate("word ", 400),
        slug: "long",
        description: "Long",
        image_path: "/test.jpg",
        category_id: category.id
      }

      changeset = Post.changeset(%Post{}, long_post)
      assert Ecto.Changeset.get_change(changeset, :read_time) == 2
    end
  end

  describe "format_read_time/1" do
    test "formats read time correctly" do
      assert Post.format_read_time(%Post{read_time: 1}) == "1 minute"
      assert Post.format_read_time(%Post{read_time: 5}) == "5 minutes"
      assert Post.format_read_time(%Post{read_time: 0}) == "0 minutes"
    end
  end

  defp insert(:category) do
    Website.Repo.insert!(%Website.Blog.Category{
      name: "Test",
      slug: "test-#{:rand.uniform(1000)}",
      description: "Test category"
    })
  end
end
