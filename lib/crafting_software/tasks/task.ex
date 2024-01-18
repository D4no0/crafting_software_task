defmodule CraftingSoftware.Tasks.Task do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:name, :string)
    field(:command, :string)
    field(:requires, {:array, :string})
  end

  def changeset(task, attrs) do
    task
    |> cast(attrs, [:name, :command, :requires])
    |> validate_required([:name, :command])
  end
end
