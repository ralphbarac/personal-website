defmodule Website.ConfigTest do
  use ExUnit.Case, async: true

  alias Website.Config

  describe "get/3" do
    test "returns configured value" do
      Application.put_env(:website, :test_key, "test_value")
      assert Config.get(:website, :test_key) == "test_value"
    end

    test "returns default when key not found" do
      assert Config.get(:website, :missing_key, "default") == "default"
    end

    test "returns nil when no default provided" do
      assert Config.get(:website, :missing_key) == nil
    end
  end

  describe "get_env/2" do
    test "returns environment variable value" do
      System.put_env("TEST_VAR", "test_value")
      assert Config.get_env("TEST_VAR") == "test_value"
      System.delete_env("TEST_VAR")
    end

    test "returns default when env var not set" do
      assert Config.get_env("MISSING_VAR", "default") == "default"
    end

    test "returns nil when env var not set and no default" do
      assert Config.get_env("MISSING_VAR") == nil
    end
  end

  describe "get_env!/1" do
    test "returns environment variable value" do
      System.put_env("REQUIRED_VAR", "required_value")
      assert Config.get_env!("REQUIRED_VAR") == "required_value"
      System.delete_env("REQUIRED_VAR")
    end

    test "raises when environment variable missing" do
      assert_raise RuntimeError, ~r/Environment variable MISSING_REQUIRED_VAR is required/, fn ->
        Config.get_env!("MISSING_REQUIRED_VAR")
      end
    end
  end

  describe "get_secret_key_base/1" do
    test "uses environment variable when set for dev" do
      System.put_env("SECRET_KEY_BASE", "env_secret")
      assert Config.get_secret_key_base(:dev) == "env_secret"
      System.delete_env("SECRET_KEY_BASE")
    end

    test "generates development secret when env var not set for dev" do
      System.delete_env("SECRET_KEY_BASE")
      secret = Config.get_secret_key_base(:dev)
      assert is_binary(secret)
      assert String.length(secret) == 64
    end

    test "requires environment variable for production" do
      System.delete_env("SECRET_KEY_BASE")

      assert_raise RuntimeError, ~r/Environment variable SECRET_KEY_BASE is required/, fn ->
        Config.get_secret_key_base(:prod)
      end
    end
  end

  describe "validate_config!/0" do
    test "succeeds in test environment" do
      # Should not raise in test environment
      assert :ok = Config.validate_config!()
    end
  end
end
