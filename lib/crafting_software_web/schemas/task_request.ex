defmodule CraftingSoftwareWeb.Schemas.TaskRequest do
  @moduledoc false
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Task request schema",
    description: "A task schema",
    type: :object,
    properties: %{
      name: %Schema{type: :string, description: "Task name"},
      command: %Schema{type: :string, description: "Command"},
      requires: %Schema{type: :array, items: %Schema{type: :string, description: "Required task"}}
    },
    required: [:name, :command],
    example: %{
      "name" => "task-2",
      "command" => "cat /tmp/file1",
      "requires" => ["task-1"]
    }
  })
end
