defmodule Website.Utils.FormatHelpersTest do
  use ExUnit.Case, async: true
  
  alias Website.Utils.FormatHelpers

  describe "format_minutes/1" do
    test "formats 1 minute as singular" do
      assert FormatHelpers.format_minutes(1) == "1 minute"
    end

    test "formats 0 minutes as plural" do
      assert FormatHelpers.format_minutes(0) == "0 minutes"
    end

    test "formats multiple minutes as plural" do
      assert FormatHelpers.format_minutes(5) == "5 minutes"
      assert FormatHelpers.format_minutes(15) == "15 minutes"
      assert FormatHelpers.format_minutes(60) == "60 minutes"
    end
  end

  describe "format_seconds/1" do
    test "formats seconds only when under 1 minute" do
      assert FormatHelpers.format_seconds(30) == "30 seconds"
      assert FormatHelpers.format_seconds(1) == "1 second"
      assert FormatHelpers.format_seconds(45) == "45 seconds"
    end

    test "formats minutes only when no hours" do
      assert FormatHelpers.format_seconds(60) == "1 minute"
      assert FormatHelpers.format_seconds(120) == "2 minutes"
      assert FormatHelpers.format_seconds(3540) == "59 minutes"
    end

    test "formats hours only when exact hour" do
      assert FormatHelpers.format_seconds(3600) == "1 hour"
      assert FormatHelpers.format_seconds(7200) == "2 hours"
    end

    test "formats hours and minutes when both present" do
      assert FormatHelpers.format_seconds(3661) == "1 hour, 1 minute"
      assert FormatHelpers.format_seconds(3720) == "1 hour, 2 minutes"
      assert FormatHelpers.format_seconds(7260) == "2 hours, 1 minute"
      assert FormatHelpers.format_seconds(7320) == "2 hours, 2 minutes"
    end

    test "handles edge cases" do
      assert FormatHelpers.format_seconds(0) == "0 seconds"
      assert FormatHelpers.format_seconds(59) == "59 seconds"
      assert FormatHelpers.format_seconds(3599) == "59 minutes"
    end
  end

  describe "pluralize/2" do
    test "returns singular form for count of 1" do
      assert FormatHelpers.pluralize(1, "item") == "item"
      assert FormatHelpers.pluralize(1, "hour") == "hour"
      assert FormatHelpers.pluralize(1, "minute") == "minute"
    end

    test "returns plural form for count of 0" do
      assert FormatHelpers.pluralize(0, "item") == "items"
      assert FormatHelpers.pluralize(0, "hour") == "hours"
    end

    test "returns plural form for count greater than 1" do
      assert FormatHelpers.pluralize(2, "item") == "items"
      assert FormatHelpers.pluralize(5, "hour") == "hours"
      assert FormatHelpers.pluralize(100, "minute") == "minutes"
    end
  end
end