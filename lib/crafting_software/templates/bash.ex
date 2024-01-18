defmodule CraftingSoftware.Templates.Bash do
  @moduledoc """
    This module contains functions for rendering the bash output based on template.
  """

  @doc """
    Renders a bash template containing the list of commands passed.
  """
  @spec render_bash_template(commands :: list(String.t())) :: String.t()
  def render_bash_template(commands) do
    {result, _} = Code.eval_quoted(bash_template(), assigns: [commands: commands])
    result
  end

  # Can be moved to compile-time, kept at runtime for simplicity
  defp bash_template() do
    priv_dir =
      :crafting_software
      |> :code.priv_dir()
      |> to_string()

    Path.join([priv_dir, "templates", "bash_template.eex"])
    |> EEx.compile_file()
  end
end
