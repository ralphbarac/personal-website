defmodule Website.Utils.FormatHelpers do
  @moduledoc """
  General utility functions for formatting strings, times, and other data.

  Provides reusable formatting functions that can be used across different
  modules in the application.
  """

  @doc """
  Formats a time duration in minutes into a human-readable string.

  ## Examples

      iex> Website.Utils.FormatHelpers.format_minutes(1)
      "1 minute"

      iex> Website.Utils.FormatHelpers.format_minutes(5)
      "5 minutes"

      iex> Website.Utils.FormatHelpers.format_minutes(0)
      "0 minutes"
  """
  def format_minutes(minutes) when is_integer(minutes) do
    case minutes do
      1 -> "1 minute"
      _ -> "#{minutes} minutes"
    end
  end

  @doc """
  Formats seconds into a human-readable duration string.

  ## Examples

      iex> Website.Utils.FormatHelpers.format_seconds(60)
      "1 minute"

      iex> Website.Utils.FormatHelpers.format_seconds(3661)
      "1 hour, 1 minute"
  """
  def format_seconds(seconds) when is_integer(seconds) do
    hours = div(seconds, 3600)
    minutes = div(rem(seconds, 3600), 60)

    cond do
      hours > 0 && minutes > 0 ->
        "#{hours} #{pluralize(hours, "hour")}, #{minutes} #{pluralize(minutes, "minute")}"

      hours > 0 ->
        "#{hours} #{pluralize(hours, "hour")}"

      minutes > 0 ->
        "#{minutes} #{pluralize(minutes, "minute")}"

      true ->
        "#{seconds} #{pluralize(seconds, "second")}"
    end
  end

  @doc """
  Pluralizes a word based on a count.

  ## Examples

      iex> Website.Utils.FormatHelpers.pluralize(1, "item")
      "item"

      iex> Website.Utils.FormatHelpers.pluralize(2, "item")
      "items"
  """
  def pluralize(1, word), do: word
  def pluralize(_, word), do: word <> "s"
end
