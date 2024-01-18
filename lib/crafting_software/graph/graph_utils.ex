defmodule CraftingSoftware.GraphUtils do
  @moduledoc """
    Utility functions for working with erlang :digraph and tasks
  """
  alias CraftingSoftware.Tasks.Task

  @doc """
    Adds vertices and dependent edges to the graph from a list of Task struct.

    Duplicated vertices names are unified, meaning that if you have 2 tasks with name "task1",
    a vertex with name "task1" will be created and all the edges from their dependency list.

    To have cyclic dependencies check at this stage ensure that the graph was created with :acyclic option.
  """
  @spec add_data(:digraph.graph(), nonempty_list(Task.t())) ::
          {:ok, :digraph.graph()} | {:error, list()}
  def add_data(graph, tasks) do
    # Adding vertices
    for task <- tasks do
      :digraph.add_vertex(graph, task.name)
    end

    # Adding edges
    edges =
      Enum.flat_map(tasks, fn task ->
        if task.requires != nil do
          for edge <- task.requires do
            :digraph.add_edge(graph, task.name, edge)
          end
        else
          []
        end
      end)

    case check_error_edges(edges) do
      [] -> {:ok, graph}
      errors -> {:error, errors}
    end
  end

  # Returns all errors from the inserted edges
  @spec check_error_edges(edges :: list()) :: list()
  defp check_error_edges(edges) do
    check_error_edges([], edges)
  end

  @spec check_error_edges(acc :: list(), edges :: list()) :: list()
  defp check_error_edges(acc, []), do: acc

  defp check_error_edges(acc, [{:error, reason} | t]) do
    check_error_edges([{:error, reason} | acc], t)
  end

  defp check_error_edges(acc, [_edge | t]) do
    check_error_edges(acc, t)
  end

  @doc """
    Returns a list of vertices names sorted based on their dependencies.

    This algorithm will iteratively remove vertices from graph that have no incident edges,
    the edges then are added to the resulting list. A failsafe mechanism is implemented in case of cyclic
    dependencies, however it is strongly encouraged usage of a acyclic graph.
  """
  @spec sort_dependencies(:digraph.graph()) ::
          {:ok, list(String.t())} | {:error, :cyclic_dependency}
  def sort_dependencies(original_graph) do
    # Create a temporary graph to avoid mutations on original graph
    graph =
      :digraph_utils.subgraph(original_graph, :digraph.vertices(original_graph), type: :inherit)

    result = sort_dependencies([], :digraph.no_vertices(graph), graph)

    # Remove temporary graph
    :digraph.delete(graph)

    result
  end

  defp sort_dependencies(acc, no_vertices, _graph) when no_vertices == 0 do
    {:ok, acc}
  end

  defp sort_dependencies(acc, _no_vertices, graph) do
    vertices = :digraph.vertices(graph)

    free_vertices =
      Enum.filter(vertices, fn vertex ->
        edges_no =
          graph
          |> :digraph.out_edges(vertex)
          |> Enum.count()

        edges_no == 0
      end)

    # failsafe if the graph has cyclic dependencies
    if Enum.empty?(free_vertices) do
      {:error, :cyclic_dependency}
    else
      # Remove free vertices from graph
      :digraph.del_vertices(graph, free_vertices)

      sort_dependencies(
        acc ++ free_vertices,
        :digraph.no_vertices(graph),
        graph
      )
    end
  end
end
