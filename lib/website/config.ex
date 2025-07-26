defmodule Website.Config do
  @moduledoc """
  Configuration management and validation for the Website application.

  Provides utilities for:
  - Validating required environment variables
  - Loading configuration with proper defaults
  - Environment-specific configuration helpers
  """

  require Logger

  @doc """
  Validates required configuration values on application startup.

  This function should be called during application startup to ensure
  all required configuration is present and valid.
  """
  def validate_config! do
    validate_environment_config!()
    validate_database_config!()
    validate_endpoint_config!()
    validate_mailer_config!()

    Logger.info("Configuration validation completed successfully")
  end

  @doc """
  Gets a configuration value with a default fallback.

  ## Examples

      iex> Website.Config.get(:website, :some_key, "default")
      "configured_value"
  """
  def get(app, key, default \\ nil) do
    Application.get_env(app, key, default)
  end

  @doc """
  Gets an environment variable with validation.

  ## Examples

      iex> Website.Config.get_env!("DATABASE_URL")
      "ecto://user:pass@localhost/db"
      
      iex> Website.Config.get_env!("MISSING_VAR")
      ** (RuntimeError) Environment variable MISSING_VAR is required but not set
  """
  def get_env!(var_name) do
    System.get_env(var_name) ||
      raise """
      Environment variable #{var_name} is required but not set.
      Please set this variable in your environment or .env file.
      """
  end

  @doc """
  Gets an environment variable with a default value.
  """
  def get_env(var_name, default \\ nil) do
    System.get_env(var_name, default)
  end

  @doc """
  Generates a secure secret key base for development/test if not provided.
  """
  def get_secret_key_base(env) when env in [:dev, :test] do
    System.get_env("SECRET_KEY_BASE") || generate_dev_secret()
  end

  def get_secret_key_base(:prod) do
    get_env!("SECRET_KEY_BASE")
  end

  # Private functions

  defp validate_environment_config! do
    env = config_env()

    unless env in [:dev, :test, :prod] do
      raise "Invalid MIX_ENV: #{env}. Must be one of: dev, test, prod"
    end
  end

  defp validate_database_config! do
    if config_env() == :prod do
      get_env!("DATABASE_URL")
    end
  end

  defp validate_endpoint_config! do
    if config_env() == :prod do
      get_env!("SECRET_KEY_BASE")
      get_env!("PHX_HOST")
    end
  end

  defp validate_mailer_config! do
    if config_env() == :prod do
      # Add validation for production mailer configuration if needed
      :ok
    else
      :ok
    end
  end

  defp generate_dev_secret do
    # Generate a consistent but unique secret for development
    base_secret =
      :crypto.hash(:sha256, "website-dev-secret-#{node()}")
      |> Base.encode64()

    # Ensure we have exactly 64 characters by repeating if needed
    String.slice(base_secret <> base_secret, 0, 64)
  end

  defp config_env do
    Application.get_env(:website, :config_env) || Mix.env()
  end
end
