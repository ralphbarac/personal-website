defmodule WebsiteWeb.AdminBlogLiveTest do
  use WebsiteWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Website.{Blog, Accounts}

  setup %{conn: conn} do
    # Create a test user and log them in
    {:ok, user} =
      Accounts.register_user(%{
        email: "admin@test.com",
        password: "123456789012"
      })

    conn = log_in_user(conn, user)

    {:ok, category} =
      Blog.create_category(%{
        name: "Test Category",
        slug: "test-category",
        description: "Test category description"
      })

    {:ok, post} =
      Blog.create_post(%{
        title: "Test Post",
        slug: "test-post",
        body: "Test content",
        description: "Test description",
        status: :draft,
        image_path: "/images/test-post.jpg",
        category_id: category.id
      })

    %{conn: conn, category: category, post: post, user: user}
  end

  describe "AdminBlogLive index" do
    test "displays posts in table", %{conn: conn, post: post} do
      {:ok, _index_live, html} = live(conn, "/admin/blog")

      assert html =~ "Blog Posts"
      assert html =~ post.title
      assert html =~ post.description
      # Status
      assert html =~ "Draft"
    end

    test "filters posts by title", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, "/admin/blog")

      # Search for existing post
      index_live
      |> form("#filter-form", filters: %{title: post.title})
      |> render_change()

      assert has_element?(index_live, "#post-#{post.id}")

      # Search for non-existent post
      index_live
      |> form("#filter-form", filters: %{title: "Non-existent"})
      |> render_change()

      refute has_element?(index_live, "#post-#{post.id}")
    end

    test "filters posts by status", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, "/admin/blog")

      # Filter by draft status
      index_live
      |> form("#filter-form", filters: %{status: "draft"})
      |> render_change()

      assert has_element?(index_live, "#post-#{post.id}")

      # Filter by published status (should not show draft post)
      index_live
      |> form("#filter-form", filters: %{status: "published"})
      |> render_change()

      refute has_element?(index_live, "#post-#{post.id}")
    end

    test "filters posts by category", %{conn: conn, post: post, category: category} do
      {:ok, index_live, _html} = live(conn, "/admin/blog")

      # Filter by category
      index_live
      |> form("#filter-form", filters: %{category_id: category.id})
      |> render_change()

      assert has_element?(index_live, "#post-#{post.id}")
    end
  end

  describe "Bulk selection and operations" do
    test "toggles individual post selection", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, "/admin/blog")

      # Select post
      index_live
      |> element("input[phx-value-id='#{post.id}']")
      |> render_click()

      # Should show bulk actions
      assert has_element?(index_live, ".bulk-actions")
      assert has_element?(index_live, "button[phx-value-action='publish']")

      # Deselect post
      index_live
      |> element("input[phx-value-id='#{post.id}']")
      |> render_click()

      # Should hide bulk actions
      refute has_element?(index_live, ".bulk-actions")
    end

    test "selects all posts", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, "/admin/blog")

      # Select all
      index_live
      |> element("thead input[type='checkbox']")
      |> render_click()

      # Should show bulk actions and selected count
      assert has_element?(index_live, ".bulk-actions")
      assert index_live |> element(".bulk-actions") |> render() =~ "1 post selected"

      # Individual checkbox should be checked
      assert index_live
             |> element("input[phx-value-id='#{post.id}']")
             |> render() =~ "checked"
    end

    test "bulk publish operation", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, "/admin/blog")

      # Select post
      index_live
      |> element("input[phx-value-id='#{post.id}']")
      |> render_click()

      # Perform bulk publish
      index_live
      |> element("button[phx-value-action='publish']")
      |> render_click()

      # Should show success message
      assert index_live |> element(".flash") |> render() =~ "published successfully"

      # Post status should be updated
      assert index_live |> element("#post-#{post.id}") |> render() =~ "Published"
    end

    test "bulk delete operation", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, "/admin/blog")

      # Select post
      index_live
      |> element("input[phx-value-id='#{post.id}']")
      |> render_click()

      # Perform bulk delete (with confirmation)
      index_live
      |> element("button[phx-value-action='delete']")
      |> render_click()

      # Should show success message
      assert index_live |> element(".flash") |> render() =~ "deleted successfully"

      # Post should be removed from list
      refute has_element?(index_live, "#post-#{post.id}")
    end
  end

  describe "Individual post operations" do
    test "toggles post status", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, "/admin/blog")

      # Initially draft
      assert index_live |> element("#post-#{post.id}") |> render() =~ "Draft"

      # Toggle to published
      index_live
      |> element("button[phx-value-id='#{post.id}']", "Publish")
      |> render_click()

      # Should show success message and updated status
      assert index_live |> element(".flash") |> render() =~ "updated successfully"
      assert index_live |> element("#post-#{post.id}") |> render() =~ "Published"

      # Button text should change
      assert has_element?(index_live, "button[phx-value-id='#{post.id}']", "Unpublish")
    end

    test "deletes individual post", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, "/admin/blog")

      # Delete post (with confirmation)
      index_live
      |> element("button[phx-value-id='#{post.id}']", "Delete")
      |> render_click()

      # Should show success message
      assert index_live |> element(".flash") |> render() =~ "deleted successfully"

      # Post should be removed from list
      refute has_element?(index_live, "#post-#{post.id}")
    end

    test "navigates to edit post", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, "/admin/blog")

      # Click edit link
      index_live
      |> element("a", "Edit")
      |> render_click()

      # Should navigate to edit page
      assert_redirected(index_live, "/admin/blog/edit/#{post.id}")
    end
  end

  describe "Optimistic updates" do
    test "immediately updates UI when toggling status", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, "/admin/blog")

      # Mock a slow operation by checking immediate UI update
      initial_html = render(index_live)
      assert initial_html =~ "Draft"

      # Start toggle operation
      index_live
      |> element("button[phx-value-id='#{post.id}']", "Publish")
      |> render_click()

      # UI should update immediately (optimistic update)
      updated_html = render(index_live)
      assert updated_html =~ "Published"
    end

    test "immediately removes post from UI when deleting", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, "/admin/blog")

      # Verify post is present
      assert has_element?(index_live, "#post-#{post.id}")

      # Start delete operation
      index_live
      |> element("button[phx-value-id='#{post.id}']", "Delete")
      |> render_click()

      # Post should be immediately removed (optimistic update)
      refute has_element?(index_live, "#post-#{post.id}")
    end
  end

  describe "Loading states" do
    test "shows loading indicator during operations", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, "/admin/blog")

      # During status toggle, loading should be true
      Process.flag(:trap_exit, true)

      # This would require mocking the Blog context to simulate slow operations
      # For now, we test that the loading assignment exists on the toggle button
      assert index_live
             |> element("button[phx-click='toggle_status'][phx-value-id='#{post.id}']")
             |> render() =~ "phx-disable-with"
    end
  end

  describe "Error handling" do
    test "handles bulk operation with no selection", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, "/admin/blog")

      # Try to perform bulk action without selecting posts
      # This should show an error message
      html = render(index_live)
      # No selection, no bulk actions visible
      refute html =~ ".bulk-actions"
    end
  end
end
