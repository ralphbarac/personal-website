defmodule WebsiteWeb.RSSController do
  use WebsiteWeb, :controller

  alias Website.Blog.Posts

  def feed(conn, _params) do
    rss_config = Application.get_env(:website, :rss)
    posts = Posts.list_published_posts_for_rss(rss_config[:max_items])

    # Generate ETag from latest post timestamp and post count for caching
    etag = generate_etag(posts)
    last_modified = get_last_modified(posts)

    conn = 
      conn
      |> put_resp_content_type("application/rss+xml")
      |> put_resp_header("cache-control", "public, max-age=#{rss_config[:cache_ttl]}")
      |> put_resp_header("etag", etag)
      |> put_resp_header("last-modified", last_modified)

    # Check if client has cached version
    case get_req_header(conn, "if-none-match") do
      [^etag] -> 
        conn |> send_resp(304, "")
      _ ->
        # Render the RSS XML template manually
        assigns = %{
          posts: posts,
          rss_config: rss_config,
          site_url: get_site_url(conn)
        }
        
        rss_content = WebsiteWeb.RSSHTML.feed(assigns)
        
        send_resp(conn, 200, rss_content)
    end
  end

  defp generate_etag(posts) do
    case posts do
      [] -> 
        "empty"
      [latest | _] -> 
        hash_data = "#{DateTime.to_iso8601(latest.updated_at)}-#{length(posts)}"
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