defmodule CraftingSoftwareWeb.Router do
  use CraftingSoftwareWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: CraftingSoftwareWeb.ApiSpec
  end

  scope "/" do
    get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
  end

  scope "/api" do
    pipe_through :api

    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end

  scope "/api/tasks", CraftingSoftwareWeb do
    pipe_through :api

    post "/create", TaskController, :create
  end
end
