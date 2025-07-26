defmodule WebsiteWeb.PageTitle do
  @moduledoc """
  Handles page title formatting for all LiveView pages.
  """

  import Phoenix.Component
  import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    socket = attach_hook(socket, :page_title, :handle_params, &handle_page_title/3)
    {:cont, socket}
  end

  defp handle_page_title(_params, _uri, socket) do
    base_title = socket.assigns[:base_title]

    formatted_title =
      case base_title do
        nil -> "Ralph Barac"
        title -> "#{title} • Ralph Barac"
      end

    socket = assign(socket, :page_title, formatted_title)
    {:cont, socket}
  end
end
