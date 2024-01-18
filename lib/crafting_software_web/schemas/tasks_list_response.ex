defmodule CraftingSoftwareWeb.Schemas.TasksListResponse do
  @moduledoc false
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Tasks list response",
    description: "A list of sorted tasks sent as response",
    type: :object,
    properties: %{
      tasks: %Schema{type: :array, items: CraftingSoftwareWeb.Schemas.TaskRequest},
      bash_output: %Schema{type: :string}
    },
    required: [:tasks],
    example: %{
      "task" => [
        %{
          "command" => "touch /tmp/file1",
          "name" => "task-1"
        },
        %{
          "command" => "echo 'Hello World!' > /tmp/file1",
          "name" => "task-3"
        },
        %{
          "command" => "cat /tmp/file1",
          "name" => "task-2"
        },
        %{
          "command" => "rm /tmp/file1",
          "name" => "task-4"
        }
      ],
      "bash_output" =>
        "#!/usr/bin/env bash\ntouch /tmp/file1\necho 'Hello World!' > /tmp/file1\ncat /tmp/file1\nrm /tmp/file1"
    }
  })
end
