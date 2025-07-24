defmodule WebsiteWeb.RSSControllerTest do
  use WebsiteWeb.ConnCase

  alias Website.Blog
  alias Website.Blog.{Post, Category}
  alias Website.Repo

  describe "GET /feed.xml" do
    test "returns RSS feed with correct content type", %{conn: conn} do
      conn = get(conn, ~p"/feed.xml")
      assert response_content_type(conn, :xml) =~ "application/rss+xml"
      assert conn.status == 200
    end

    test "returns valid RSS 2.0 structure", %{conn: conn} do
      conn = get(conn, ~p"/feed.xml")
      response = response(conn, 200)
      
      assert response =~ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
      assert response =~ "<rss version=\"2.0\""
      assert response =~ "<channel>"
      assert response =~ "<title>Ralph Barac's Blog</title>"
      assert response =~ "</channel>"
      assert response =~ "</rss>"
    end

    test "includes published posts in feed", %{conn: conn} do
      # Create a test category
      {:ok, category} = Blog.create_category(%{
        name: "Test Category",
        slug: "test-category", 
        description: "Test category description"
      })

      # Create a published post
      {:ok, _post} = Blog.create_post(%{
        title: "Test Post",
        body: "<p>Test content</p>",
        slug: "test-post",
        description: "Test description",
        status: :published,
        category_id: category.id,
        image_path: "/images/blog/test.jpg"
      })

      conn = get(conn, ~p"/feed.xml")
      response = response(conn, 200)
      
      assert response =~ "Test Post"
      assert response =~ "Test content"
      assert response =~ "/blog/posts/test-post"
    end

    test "does not include draft posts in feed", %{conn: conn} do
      # Create a test category
      {:ok, category} = Blog.create_category(%{
        name: "Test Category",
        slug: "test-category",
        description: "Test category description"
      })

      # Create a draft post
      {:ok, _post} = Blog.create_post(%{
        title: "Draft Post",
        body: "<p>Draft content</p>",
        slug: "draft-post",
        description: "Draft description",
        status: :draft,
        category_id: category.id,
        image_path: "/images/blog/draft.jpg"
      })

      conn = get(conn, ~p"/feed.xml")
      response = response(conn, 200)
      
      refute response =~ "Draft Post"
      refute response =~ "Draft content"
    end

    test "returns proper caching headers", %{conn: conn} do
      conn = get(conn, ~p"/feed.xml")
      
      assert get_resp_header(conn, "cache-control") == ["public, max-age=3600"]
      assert get_resp_header(conn, "etag") != []
      assert get_resp_header(conn, "last-modified") != []
    end

    test "handles empty feed gracefully", %{conn: conn} do
      # Ensure no published posts exist
      Repo.delete_all(Post)
      
      conn = get(conn, ~p"/feed.xml")
      response = response(conn, 200)
      
      assert response =~ "<channel>"
      assert response =~ "<title>Ralph Barac's Blog</title>"
      # Should not have any <item> elements
      refute response =~ "<item>"
    end
  end
end