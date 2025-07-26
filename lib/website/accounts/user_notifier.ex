defmodule Website.Accounts.UserNotifier do
  @moduledoc """
  User notification system (currently disabled).

  This module would handle email notifications for user authentication events
  like account confirmation, password resets, and email updates. For this
  single-admin setup, all notifications are disabled.
  """
  # Email notifications are disabled for this single-admin setup
  # All notification functions return {:ok, :no_email_sent}

  def deliver_confirmation_instructions(_user, _url), do: {:ok, :no_email_sent}
  def deliver_reset_password_instructions(_user, _url), do: {:ok, :no_email_sent}
  def deliver_update_email_instructions(_user, _url), do: {:ok, :no_email_sent}
end
