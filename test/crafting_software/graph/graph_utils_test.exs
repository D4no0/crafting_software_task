defmodule CraftingSoftware.GraphUtilsTest do
  use ExUnit.Case, async: false

  alias CraftingSoftware.GraphUtils
  alias CraftingSoftware.Tasks.Task

  test "add_data/2 creates a valid graph correctly" do
    graph = :digraph.new([:acyclic])

    tasks = [
      %Task{
        name: "task-1",
        command: "touch /tmp/file1"
      },
      %Task{
        name: "task-2",
        command: "cat /tmp/file1",
        requires: ["task-3"]
      },
      %Task{
        name: "task-3",
        command: "echo 'Hello World!' > /tmp/file1",
        requires: ["task-1"]
      },
      %Task{
        name: "task-4",
        command: "rm /tmp/file1",
        requires: ["task-2", "task-3"]
      }
    ]

    {:ok, graph} = GraphUtils.add_data(graph, tasks)

    assert :digraph.no_vertices(graph) == 4
    assert :digraph.no_edges(graph) == 4
  end

  test "add_data/2 returns error when a invalid task name in requires is passed" do
    graph = :digraph.new([:acyclic])

    tasks = [
      %Task{
        name: "task-1",
        command: "touch /tmp/file1"
      },
      %Task{
        name: "task-2",
        command: "cat /tmp/file1",
        requires: ["task-3", "invalid-task"]
      },
      %Task{
        name: "task-3",
        command: "echo 'Hello World!' > /tmp/file1",
        requires: ["task-1"]
      },
      %Task{
        name: "task-4",
        command: "rm /tmp/file1",
        requires: ["task-2", "invalid-task"]
      }
    ]

    assert {:error, errors} = GraphUtils.add_data(graph, tasks)
    assert Enum.count(errors) == 2

    for error <- errors do
      assert {:error, {:bad_vertex, _name}} = error
    end
  end

  test "add_data/2 returns error on cyclic dependency" do
    graph = :digraph.new([:acyclic])

    tasks = [
      %Task{
        name: "task-1",
        command: "touch /tmp/file1"
      },
      %Task{
        name: "task-2",
        command: "cat /tmp/file1",
        requires: ["task-3"]
      },
      %Task{
        name: "task-3",
        command: "echo 'Hello World!' > /tmp/file1",
        requires: ["task-1", "task-2"]
      },
      %Task{
        name: "task-4",
        command: "rm /tmp/file1",
        requires: ["task-2"]
      }
    ]

    assert {:error, errors} = GraphUtils.add_data(graph, tasks)

    for error <- errors do
      assert {:error, {:bad_edge, _edges}} = error
    end
  end

  test "sort_dependencies/1 sorts dependencies correctly" do
    graph = :digraph.new([:acyclic])

    # The structure used
    # tasks = [
    #   %Task{
    #     name: "task-5",
    #     command: "echo $0",
    #     requires: ["task-4"]
    #   },
    #   %Task{
    #     name: "task-1",
    #     command: "touch /tmp/file1"
    #   },
    #   %Task{
    #     name: "task-2",
    #     command: "cat /tmp/file1",
    #     requires: ["task-3"]
    #   },
    #   %Task{
    #     name: "task-3",
    #     command: "echo 'Hello World!' > /tmp/file1",
    #     requires: ["task-1"]
    #   },
    #   %Task{
    #     name: "task-4",
    #     command: "rm /tmp/file1",
    #     requires: ["task-2", "task-3"]
    #   }
    # ]

    add_vertices(graph, ["task-1", "task-3", "task-2", "task-4", "task-5"])

    add_edges(graph, [
      {"task-2", "task-3"},
      {"task-3", "task-1"},
      {"task-4", "task-2"},
      {"task-4", "task-3"},
      {"task-5", "task-4"}
    ])

    assert {:ok, result} = GraphUtils.sort_dependencies(graph)
    assert ["task-1", "task-3", "task-2", "task-4", "task-5"] = result
  end

  defp add_vertices(graph, vertices_list) when is_list(vertices_list) do
    for vertex <- vertices_list do
      :digraph.add_vertex(graph, vertex)
    end
  end

  defp add_edges(graph, pair_list) when is_list(pair_list) do
    for {v1, v2} <- pair_list do
      :digraph.add_edge(graph, v1, v2)
    end
  end

  test "sort_dependencies/1 cyclic dependency failsafe trigger" do
    # No acyclic graph on propose
    graph = :digraph.new()

    add_vertices(graph, ["task-1", "task-3", "task-2"])

    add_edges(graph, [
      {"task-1", "task-3"},
      {"task-3", "task-2"},
      {"task-2", "task-1"}
    ])

    assert {:error, :cyclic_dependency} = GraphUtils.sort_dependencies(graph)
  end

  test "sort_dependencies/1 with one entry" do
    graph = :digraph.new([:acyclic])
    add_vertices(graph, ["task-1"])

    assert {:ok, ["task-1"]} = GraphUtils.sort_dependencies(graph)
  end
end
