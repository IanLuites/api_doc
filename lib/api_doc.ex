defmodule APIDoc do
  @moduledoc ~S"""
  API documentation generator for Elixir.
  """

  @doc false
  defmacro __using__(opts \\ []) do
    if Plug.Builder in Keyword.keys(__CALLER__.macros) do
      quote do
        use APIDoc.PlugRouterDocumenter, unquote(opts)
      end
    else
      quote do
        use APIDoc.APIDocumenter, unquote(opts)
      end
    end
  end
end
