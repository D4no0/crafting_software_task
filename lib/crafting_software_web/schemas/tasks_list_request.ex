defmodule CraftingSoftwareWeb.Schemas.TasksListRequest do
  @moduledoc false
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "A list of tasks request",
    description: "A list of tasks",
    type: :object,
    properties: %{
      tasks: %Schema{type: :array, items: CraftingSoftwareWeb.Schemas.TaskRequest}
    },
    required: [:tasks],
    example: %{
      "tasks" => [
        %{
          "name" => "task-1",
          "command" => "touch /tmp/file1"
        },
        %{
          "name" => "task-2",
          "command" => "cat /tmp/file1",
          "requires" => [
            "task-3"
          ]
        },
        %{
          "name" => "task-3",
          "command" => "echo 'Hello World!' > /tmp/file1",
          "requires" => [
            "task-1"
          ]
        },
        %{
          "name" => "task-4",
          "command" => "rm /tmp/file1",
          "requires" => [
            "task-2",
            "task-3"
          ]
        }
      ]
    }
  })
end
