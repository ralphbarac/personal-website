defmodule WebsiteWeb.RSSHTML do
  @moduledoc """
  This module contains pages rendered by RSSController.
  """
  use WebsiteWeb, :html

  embed_templates "rss_html/*"

  # Helper function to format dates for RSS (RFC 822 format)
  def format_rss_date(datetime) do
    datetime
    |> DateTime.shift_zone!("Etc/UTC")  
    |> Calendar.strftime("%a, %d %b %Y %H:%M:%S +0000")
  end

  # Helper function to generate absolute URLs
  def absolute_url(path) do
    WebsiteWeb.Endpoint.url() <> path
  end

  # Helper function to prepare content for RSS
  def prepare_rss_content(html_content) do
    # For now, wrap in CDATA. We can enhance this later with HTML processing
    html_content
    |> String.replace("]]>", "]]]]><![CDATA[>")  # Escape any existing CDATA
  end
end