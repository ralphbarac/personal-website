defmodule WebsiteWeb.HealthControllerTest do
  use WebsiteWeb.ConnCase, async: true

  describe "GET /api/health" do
    test "returns health status", %{conn: conn} do
      conn = get(conn, "/api/health")

      assert json_response(conn, 200) == %{
               "status" => "ok",
               "timestamp" => json_response(conn, 200)["timestamp"],
               "application" => "website",
               "version" => json_response(conn, 200)["version"]
             }

      # Verify timestamp is in ISO8601 format
      assert String.match?(
               json_response(conn, 200)["timestamp"],
               ~r/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/
             )
    end

    test "has proper content type", %{conn: conn} do
      conn = get(conn, "/api/health")

      assert get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]
    end
  end
end
