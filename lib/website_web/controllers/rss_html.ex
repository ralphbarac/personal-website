defmodule WebsiteWeb.RSSHTML do
  @moduledoc """
  This module contains pages rendered by RSSController.

  Supports both RSS 2.0 and Atom 1.0 feed formats with proper date formatting
  and content preparation.
  """
  use WebsiteWeb, :html

  embed_templates "rss_html/*"

  # Helper function to format dates for RSS (RFC 822 format)
  def format_rss_date(datetime) do
    datetime
    |> DateTime.shift_zone!("Etc/UTC")
    |> Calendar.strftime("%a, %d %b %Y %H:%M:%S +0000")
  end

  # Helper function to format dates for Atom (RFC 3339 format)
  def format_atom_date(datetime) do
    datetime
    |> DateTime.shift_zone!("Etc/UTC")
    |> DateTime.to_iso8601()
  end

  # Helper function to generate absolute URLs
  def absolute_url(path) do
    WebsiteWeb.Endpoint.url() <> path
  end

  # Helper function to prepare content for RSS/Atom feeds
  def prepare_rss_content(html_content) do
    # Escape any existing CDATA and ensure content is properly formatted
    html_content
    # Escape any existing CDATA
    |> String.replace("]]>", "]]]]><![CDATA[>")
    |> String.trim()
  end
end
