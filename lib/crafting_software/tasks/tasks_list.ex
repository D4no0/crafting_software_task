defmodule CraftingSoftware.Tasks.TasksList do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  alias CraftingSoftware.Tasks.Task

  @primary_key false
  embedded_schema do
    embeds_many(:tasks, Task)
  end

  def changeset(tasks_list, attrs) do
    tasks_list
    |> cast(attrs, [])
    |> cast_embed(:tasks, with: &Task.changeset/2)
  end
end
