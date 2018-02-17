defmodule APIDoc do
  @moduledoc ~S"""
  API documentation generator for Elixir.
  """

  @doc false
  defmacro __using__(opts \\ []) do
    quote do
      use APIDoc.APIDocumenter, unquote(opts)
    end
  end
end
