defmodule WebsiteWeb.RSSController do
  @moduledoc """
  RSS and Atom feed controller for blog content.

  Provides RSS 2.0 and Atom 1.0 feeds with proper caching, content negotiation,
  and error handling.
  """

  use WebsiteWeb, :controller
  require Logger

  alias Website.Blog

  @doc """
  Serves RSS 2.0 feed for blog posts.

  Supports HTTP caching with ETags and Last-Modified headers.
  """
  def feed(conn, _params) do
    serve_feed(conn, :rss)
  end

  @doc """
  Serves Atom 1.0 feed for blog posts.

  Supports HTTP caching with ETags and Last-Modified headers.
  """
  def atom(conn, _params) do
    serve_feed(conn, :atom)
  end

  # Private function to handle both RSS and Atom feeds
  defp serve_feed(conn, format) do
    try do
      rss_config = get_feed_config()
      posts = Blog.list_published_posts_for_rss(rss_config[:max_items])

      # Generate ETag from latest post timestamp and post count for caching
      etag = generate_etag(posts, format)
      last_modified = get_last_modified(posts)

      conn =
        conn
        |> put_feed_headers(format, rss_config)
        |> put_resp_header("etag", etag)
        |> put_resp_header("last-modified", last_modified)

      # Check if client has cached version
      case get_req_header(conn, "if-none-match") do
        [^etag] ->
          conn |> send_resp(304, "")

        _ ->
          # Render the appropriate feed template
          assigns = %{
            posts: posts,
            rss_config: rss_config,
            site_url: get_site_url(conn),
            format: format
          }

          feed_content = render_feed(assigns, format)

          send_resp(conn, 200, feed_content)
      end
    rescue
      error ->
        Logger.error("Feed generation failed: #{inspect(error)}")

        conn
        |> put_status(500)
        |> put_resp_content_type("application/json")
        |> json(%{error: "Feed temporarily unavailable"})
    end
  end

  # Get feed configuration with environment-specific overrides
  defp get_feed_config do
    base_config = Application.get_env(:website, :rss, [])
    env_overrides = Application.get_env(:website, :rss_env_overrides, [])

    Keyword.merge(base_config, env_overrides)
  end

  # Set appropriate headers for feed format
  defp put_feed_headers(conn, :rss, rss_config) do
    conn
    |> put_resp_content_type("application/rss+xml; charset=utf-8")
    |> put_resp_header("cache-control", "public, max-age=#{rss_config[:cache_ttl] || 3600}")
  end

  defp put_feed_headers(conn, :atom, rss_config) do
    conn
    |> put_resp_content_type("application/atom+xml; charset=utf-8")
    |> put_resp_header("cache-control", "public, max-age=#{rss_config[:cache_ttl] || 3600}")
  end

  # Render the appropriate feed template
  defp render_feed(assigns, :rss) do
    WebsiteWeb.RSSHTML.feed(assigns)
  end

  defp render_feed(assigns, :atom) do
    WebsiteWeb.RSSHTML.atom(assigns)
  end

  # Generate ETag including format for cache differentiation
  defp generate_etag(posts, format) do
    case posts do
      [] ->
        "empty-#{format}"

      [latest | _] ->
        hash_data = "#{DateTime.to_iso8601(latest.updated_at)}-#{length(posts)}-#{format}"
        :crypto.hash(:md5, hash_data) |> Base.encode16(case: :lower)
    end
  end

  defp get_last_modified(posts) do
    case posts do
      [] ->
        DateTime.utc_now() |> format_rfc822_date()

      [latest | _] ->
        format_rfc822_date(latest.updated_at)
    end
  end

  defp format_rfc822_date(datetime) do
    # Convert to RFC 822 format for RSS (e.g., "Thu, 23 Jul 2025 10:00:00 +0000")
    datetime
    |> DateTime.shift_zone!("Etc/UTC")
    |> Calendar.strftime("%a, %d %b %Y %H:%M:%S +0000")
  end

  defp get_site_url(_conn) do
    WebsiteWeb.Endpoint.url()
  end
end
