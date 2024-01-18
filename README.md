# CraftingSoftware

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Tehnogoiess used

* **Digraph** - for solving the sort problem and detection of circular dependencies;
* **Phoenix** - for serving a http API endpoint;
* **Open_api_spex** - to generate a swaggerui interface for easy interaction with the API, located at `/swaggerui`
* **EEx** - for the bash template, unnecessary for this task, however good to have for future complexity;
* **Ecto** - for easy and clean validation of input;

## Running the solution

Execution of solution is as easy as opening [`localhost:4000/swaggerui`](http://localhost:4000/swaggerui) and locating the endpoint `/api/tasks/create`.

There you should have examples of requests and responses, make sure to notice `generate_bash` flag to get the bash output string in the response.