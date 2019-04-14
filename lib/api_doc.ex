defmodule APIDoc do
  @moduledoc ~S"""
  API documentation generator for Elixir.
  """

  @doc false
  defmacro __using__(opts \\ []) do
    keys = Keyword.keys(__CALLER__.macros)

    documenter =
      cond do
        Plug.Builder in keys -> APIDoc.PlugRouterDocumenter
        Phoenix.Router in keys -> APIDoc.PhoenixRouterDocumenter
        Phoenix.Controller in keys -> APIDoc.PhoenixControllerDocumenter
        :default -> APIDoc.APIDocumenter
      end

    quote do
      use unquote(documenter), unquote(opts)
    end
  end
end
