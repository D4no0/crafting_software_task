defmodule CraftingSoftware.TasksTest do
  use ExUnit.Case, async: true

  alias CraftingSoftware.Tasks.{TasksList, Task}
  alias CraftingSoftware.Tasks

  test "sort_tasks/1 returns correct response on successful sorting" do
    tasks = %TasksList{
      tasks: [
        %Task{
          name: "task-4",
          command: "rm /tmp/file1",
          requires: ["task-2", "task-3"]
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
          name: "task-1",
          command: "touch /tmp/file1"
        }
      ]
    }

    assert {:ok, result} =
             Tasks.sort_tasks(tasks)

    assert %TasksList{
             tasks: [
               %Task{
                 name: "task-1",
                 command: "touch /tmp/file1"
               },
               %Task{
                 name: "task-3",
                 command: "echo 'Hello World!' > /tmp/file1",
                 requires: ["task-1"]
               },
               %Task{
                 name: "task-2",
                 command: "cat /tmp/file1",
                 requires: ["task-3"]
               },
               %Task{
                 name: "task-4",
                 command: "rm /tmp/file1",
                 requires: ["task-2", "task-3"]
               }
             ]
           } = result
  end

  test "sort_tasks/1 returns bad vertex error when requires uses a invalid identifier" do
    tasks = %TasksList{
      tasks: [
        %Task{
          name: "task-4",
          command: "rm /tmp/file1",
          requires: ["task-2", "task-3"]
        },
        %Task{
          name: "task-2",
          command: "cat /tmp/file1",
          requires: ["task-3"]
        },
        %Task{
          name: "task-3",
          command: "echo 'Hello World!' > /tmp/file1",
          requires: ["error"]
        },
        %Task{
          name: "task-1",
          command: "touch /tmp/file1"
        }
      ]
    }

    assert {:error, [error: {:bad_vertex, _}]} = Tasks.sort_tasks(tasks)
  end

  test "sort_tasks/1 returns bad_edge error when there are cyclic dependencies" do
    tasks = %TasksList{
      tasks: [
        %Task{
          name: "task-4",
          command: "rm /tmp/file1",
          requires: ["task-2", "task-3"]
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
          name: "task-1",
          command: "touch /tmp/file1",
          requires: ["task-2"]
        }
      ]
    }

    assert {:error, [error: {:bad_edge, _}]} = Tasks.sort_tasks(tasks)
  end
end
