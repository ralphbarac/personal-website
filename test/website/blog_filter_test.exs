defmodule Website.BlogFilterTest do
  use Website.DataCase

  alias Website.Blog

  describe "post filtering" do
    setup do
      # Create test category
      {:ok, category1} =
        Blog.create_category(%{
          name: "Tech",
          slug: "tech",
          description: "Technology posts"
        })

      {:ok, category2} =
        Blog.create_category(%{
          name: "Life",
          slug: "life",
          description: "Life posts"
        })

      # Create test posts
      {:ok, post1} =
        Blog.create_post(%{
          title: "Elixir Guide",
          body: "Content about Elixir",
          slug: "elixir-guide",
          description: "Learn Elixir",
          status: :published,
          category_id: category1.id,
          image_path: "/images/blog/elixir.jpg"
        })

      {:ok, post2} =
        Blog.create_post(%{
          title: "Life Update",
          body: "Personal update",
          slug: "life-update",
          description: "Personal thoughts",
          status: :draft,
          category_id: category2.id,
          image_path: "/images/blog/life.jpg"
        })

      {:ok, post3} =
        Blog.create_post(%{
          title: "Phoenix Tutorial",
          body: "Learn Phoenix framework",
          slug: "phoenix-tutorial",
          description: "Phoenix guide",
          status: :published,
          category_id: category1.id,
          image_path: "/images/blog/phoenix.jpg"
        })

      %{
        category1: category1,
        category2: category2,
        post1: post1,
        post2: post2,
        post3: post3
      }
    end

    test "filtering by title", %{post1: post1} do
      posts = Blog.list_posts_admin(%{title: "Elixir"})
      assert length(posts) == 1
      assert List.first(posts).id == post1.id
    end

    test "filtering by category_id", %{category1: category1, post1: post1, post3: post3} do
      posts = Blog.list_posts_admin(%{category_id: category1.id})
      assert length(posts) == 2
      post_ids = Enum.map(posts, & &1.id) |> Enum.sort()
      expected_ids = [post1.id, post3.id] |> Enum.sort()
      assert post_ids == expected_ids
    end

    test "filtering by status", %{post1: post1, post3: post3} do
      posts = Blog.list_posts_admin(%{status: :published})
      assert length(posts) == 2
      post_ids = Enum.map(posts, & &1.id) |> Enum.sort()
      expected_ids = [post1.id, post3.id] |> Enum.sort()
      assert post_ids == expected_ids
    end

    test "combined filtering", %{category1: category1, post1: post1, post3: post3} do
      posts = Blog.list_posts_admin(%{category_id: category1.id, status: :published})
      assert length(posts) == 2
      post_ids = Enum.map(posts, & &1.id) |> Enum.sort()
      expected_ids = [post1.id, post3.id] |> Enum.sort()
      assert post_ids == expected_ids
    end

    test "no filters returns all posts", %{post1: post1, post2: post2, post3: post3} do
      posts = Blog.list_posts_admin(%{})
      assert length(posts) == 3
      post_ids = Enum.map(posts, & &1.id) |> Enum.sort()
      expected_ids = [post1.id, post2.id, post3.id] |> Enum.sort()
      assert post_ids == expected_ids
    end

    test "empty filters return all posts", %{post1: post1, post2: post2, post3: post3} do
      posts = Blog.list_posts_admin(%{title: nil, category_id: nil, status: nil})
      assert length(posts) == 3
      post_ids = Enum.map(posts, & &1.id) |> Enum.sort()
      expected_ids = [post1.id, post2.id, post3.id] |> Enum.sort()
      assert post_ids == expected_ids
    end
  end
end
