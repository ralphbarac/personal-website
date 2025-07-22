defmodule Website.ProjectsTest do
  use Website.DataCase

  alias Website.Projects

  describe "business logic" do
    test "list_projects/0 orders by featured first, then by date" do
      {:ok, status} = Projects.create_project_status(%{
        name: "Live", slug: "live", description: "Live status"
      })
      
      {:ok, regular} = Projects.create_project(%{
        title: "Regular Project",
        description: "Not featured",
        project_status_id: status.id,
        featured: false
      })
      
      {:ok, featured} = Projects.create_project(%{
        title: "Featured Project", 
        description: "Is featured",
        project_status_id: status.id,
        featured: true
      })
      
      projects = Projects.list_projects()
      
      # Featured should come first
      assert List.first(projects).featured == true
      assert List.last(projects).featured == false
    end

    test "associate_technologies/2 replaces existing associations" do
      {:ok, status} = Projects.create_project_status(%{
        name: "Live", slug: "live", description: "Live"
      })
      
      {:ok, project} = Projects.create_project(%{
        title: "Test Project",
        description: "Test",
        project_status_id: status.id
      })

      {:ok, tech1} = Projects.create_technology(%{name: "Elixir", slug: "elixir"})
      {:ok, tech2} = Projects.create_technology(%{name: "PostgreSQL", slug: "postgresql"})

      # Initial association
      {:ok, _} = Projects.associate_technologies(project, [tech1])
      
      # Replace with different technology
      {:ok, _} = Projects.associate_technologies(project, [tech2])
      
      reloaded_project = Projects.get_project!(project.id)
      tech_names = Enum.map(reloaded_project.technologies, & &1.name)
      
      assert ["PostgreSQL"] == tech_names
    end
  end
end