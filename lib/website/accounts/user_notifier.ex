defmodule Website.Accounts.UserNotifier do
  # Email notifications are disabled for this single-admin setup
  # All notification functions return {:ok, :no_email_sent}
  
  def deliver_confirmation_instructions(_user, _url), do: {:ok, :no_email_sent}
  def deliver_reset_password_instructions(_user, _url), do: {:ok, :no_email_sent}  
  def deliver_update_email_instructions(_user, _url), do: {:ok, :no_email_sent}
end