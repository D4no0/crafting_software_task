defmodule CraftingSoftware.Templates.BashTest do
  use ExUnit.Case, async: true

  alias CraftingSoftware.Templates.Bash

  test "render_bash_template\1 renders commands correctly" do
    commands = ["command1", "command2", "command3", "command4"]

    result = Bash.render_bash_template(commands)

    # split the resulting string and check for individual commands
    result =
      result
      |> String.split("\n", trim: true)
      |> Enum.drop(1)

    assert result == commands
  end
end
