defmodule CraftingSoftware.Tasks do
  @moduledoc """
    Tasks context.
  """
  alias CraftingSoftware.Tasks.TasksList
  alias CraftingSoftware.GraphUtils

  @doc """
    Validates the input tasks using a changeset.
  """
  @spec validate_tasks(attrs :: map()) :: {:ok, TasksList.t()} | {:error, Ecto.Changeset.t()}
  def validate_tasks(attrs) do
    TasksList.changeset(%TasksList{}, attrs)
    |> Ecto.Changeset.apply_action(:validate)
  end

  @doc """
    Receives a TasksList structure and sorts the tasks.

    To avoid leaking of ETS tables in random contexts this function creates a unique
    Task for every call, the timeout parameter is responsible for the wait timeout.
  """
  @spec sort_tasks(data :: TasksList.t(), timeout :: integer()) :: TasksList.t()
  def sort_tasks(%TasksList{} = data, timeout \\ 5000) do
    tasks = data.tasks

    # Avoid leak of ETS tables
    result =
      Task.async(fn ->
        graph = :digraph.new([:acyclic])

        with {:ok, graph} <- GraphUtils.add_data(graph, tasks) do
          GraphUtils.sort_dependencies(graph)
        end
      end)
      |> Task.await(timeout)

    # Return the original sorted structure
    case result do
      {:ok, keys} ->
        tasks_map = Enum.into(tasks, %{}, fn task -> {task.name, task} end)

        sorted =
          Enum.map(keys, fn key ->
            Map.fetch!(tasks_map, key)
          end)

        {:ok, Map.put(data, :tasks, sorted)}

      other ->
        other
    end
  end
end
