defmodule WebsiteWeb.PageTitleTest do
  use WebsiteWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "PageTitle hook behavior" do
    test "formats page titles correctly across navigation", %{conn: conn} do
      # Test homepage (no base_title)
      {:ok, view, html} = live(conn, ~p"/")
      assert html =~ "<title>Ralph Barac</title>"

      # Navigate to about (has base_title)
      {:ok, view, html} = live(conn, ~p"/about")
      assert html =~ "<title>About • Ralph Barac</title>"

      # Navigate to projects
      {:ok, view, html} = live(conn, ~p"/projects")
      assert html =~ "<title>Projects • Ralph Barac</title>"
    end

    test "blog post shows dynamic title", %{conn: conn} do
      # Create a test post
      category = Website.Repo.insert!(%Website.Blog.Category{
        name: "Tech", slug: "tech", description: "Tech posts"
      })
      
      post = Website.Repo.insert!(%Website.Blog.Post{
        title: "Test Post Title",
        body: "Content",
        slug: "test-post",
        description: "Test",
        image_path: "/test.jpg",
        category_id: category.id,
        read_time: 1
      })

      {:ok, _view, html} = live(conn, ~p"/blog/posts/#{post.id}")
      assert html =~ "<title>Test Post Title • Ralph Barac</title>"
    end
  end
end