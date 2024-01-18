defmodule CraftingSoftwareWeb.TaskControllerTest do
  use CraftingSoftwareWeb.ConnCase, async: true

  test "POST /api/tasks/create returns the sorted list on valid input", %{conn: conn} do
    conn =
      post(conn, ~p"/api/tasks/create", %{
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
      })

    assert %{
             "tasks" => [
               %{"command" => "touch /tmp/file1", "name" => "task-1"},
               %{"command" => "echo 'Hello World!' > /tmp/file1", "name" => "task-3"},
               %{"command" => "cat /tmp/file1", "name" => "task-2"},
               %{"command" => "rm /tmp/file1", "name" => "task-4"}
             ]
           } = json_response(conn, 200)
  end

  test "POST /api/tasks/create doesn't return bash string on unset generate_bash toggle", %{
    conn: conn
  } do
    tasks = %{
      "tasks" => [
        %{
          "name" => "task-1",
          "command" => "touch /tmp/file1"
        }
      ]
    }

    conn = post(conn, ~p"/api/tasks/create", tasks)
    resp = json_response(conn, 200)

    assert Map.has_key?(resp, "bash_output") == false
  end

  test "POST /api/tasks/create doesn't return bash string on generate_bash set to false", %{
    conn: conn
  } do
    body = %{
      "tasks" => [
        %{
          "name" => "task-1",
          "command" => "touch /tmp/file1"
        }
      ]
    }

    conn = post(conn, ~p"/api/tasks/create?generate_bash=false", body)
    resp = json_response(conn, 200)

    assert Map.has_key?(resp, "bash_output") == false
  end

  test "POST /api/tasks/create returns bash string on generate_bash set to true", %{
    conn: conn
  } do
    body = %{
      "tasks" => [
        %{
          "name" => "task-1",
          "command" => "touch /tmp/file1"
        }
      ]
    }

    conn = post(conn, ~p"/api/tasks/create?generate_bash=true", body)
    resp = json_response(conn, 200)

    assert Map.has_key?(resp, "bash_output") == true
  end

  test "POST /api/tasks/create returns unprocessable entity on invalid input", %{conn: conn} do
    conn =
      post(conn, ~p"/api/tasks/create", %{
        "tasks" => [
          %{
            "name" => "task-1",
            "command" => "touch /tmp/file1"
          },
          %{
            "name" => "task-2",
            "command" => "cat /tmp/file1",
            "requires" => [
              "task-error"
            ]
          }
        ]
      })

    assert response(conn, 422)
  end

  test "POST /api/tasks/create returns unprocessable entity on circular dependencies", %{
    conn: conn
  } do
    conn =
      post(conn, ~p"/api/tasks/create", %{
        "tasks" => [
          %{
            "name" => "task-1",
            "command" => "touch /tmp/file1",
            "requires" => [
              "task-3"
            ]
          },
          %{
            "name" => "task-2",
            "command" => "cat /tmp/file1",
            "requires" => [
              "task-1"
            ]
          },
          %{
            "name" => "task-3",
            "command" => "cat /tmp/file1",
            "requires" => [
              "task-2"
            ]
          }
        ]
      })

    assert response(conn, 422)
  end
end
