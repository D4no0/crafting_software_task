defmodule CraftingSoftwareWeb.TaskController do
  use CraftingSoftwareWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias CraftingSoftware.Tasks
  alias CraftingSoftwareWeb.Schemas.{TasksListRequest, TasksListResponse}

  action_fallback CraftingSoftwareWeb.FallbackController

  operation :create,
    summary: "Sort tasks",
    description: "Sorts the given tasks based on their dependencies",
    parameters: [
      generate_bash: [
        in: :query,
        type: :boolean,
        description: "Generate output bash"
      ]
    ],
    request_body: {"The tasks to be sorted", "application/json", TasksListRequest},
    responses: %{
      200 => {"Sorted tasks response", "application/json", TasksListResponse}
    }

  def create(conn, params) do
    {generate_bash, params} =
      Map.pop(params, "generate_bash", "false")

    # Transform string parameter to boolean
    generate_bash = String.to_existing_atom(generate_bash)

    with {:ok, tasks_list} <- Tasks.validate_tasks(params),
         {:ok, sorted_tasks} <- Tasks.sort_tasks(tasks_list) do
      render(conn, "index.json", tasks: sorted_tasks.tasks, generate_bash: generate_bash)
    end
  end
end
