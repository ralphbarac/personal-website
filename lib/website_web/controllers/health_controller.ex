defmodule WebsiteWeb.HealthController do
  @moduledoc """
  Health check endpoint for monitoring and load balancer health checks.

  Provides a simple endpoint to verify the application is running and responding.
  """

  use WebsiteWeb, :controller

  @doc """
  Returns a simple health check response.

  This endpoint can be used by:
  - Load balancers to verify application health
  - Monitoring systems to check uptime
  - CI/CD pipelines to verify deployment success
  """
  def check(conn, _params) do
    # Simple health check - application is running if we reach this point
    health_status = %{
      status: "ok",
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      application: "website",
      version: Application.spec(:website, :vsn) || "unknown"
    }

    json(conn, health_status)
  end
end
