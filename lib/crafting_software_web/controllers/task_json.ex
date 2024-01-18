defmodule CraftingSoftwareWeb.TaskJSON do
  alias CraftingSoftware.Tasks.Task

  def index(%{tasks: tasks, generate_bash: generate_bash}) do
    resp = %{tasks: for(task <- tasks, do: task(task))}

    if generate_bash do
      Map.put(resp, :bash_output, generate_bash(tasks))
    else
      resp
    end
  end

  defp task(%Task{} = task) do
    %{
      name: task.name,
      command: task.command
    }
  end

  def error(%{errors: errors}) do
    %{errors: for(error <- errors, do: render_error(error))}
  end

  defp render_error({:error, {:bad_vertex, vertex}}) do
    %{vertex => "the referenced task couldn't be found"}
  end

  defp render_error({:error, {:bad_edge, edges}}) do
    edges = Enum.join(edges, ", ")
    %{edges => "these tasks are forming a circular dependency"}
  end

  defp generate_bash(tasks) do
    commands = Enum.map(tasks, fn task -> task.command end)
    CraftingSoftware.Templates.Bash.render_bash_template(commands)
  end
end
