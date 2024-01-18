defmodule CraftingSoftwareWeb.FallbackController do
  use Phoenix.Controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: CraftingSoftwareWeb.ChangesetJSON)
    |> render("error.json", changeset: changeset)
  end

  # Render bad task references and circular dependencies errors
  def call(conn, {:error, errors}) when is_list(errors) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: CraftingSoftwareWeb.TaskJSON)
    |> render("error.json", errors: errors)
  end
end
