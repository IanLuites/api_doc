defmodule APIDoc.PhoenixRouterDocumenter do
  @moduledoc ~S"""
  """

  require Logger
  alias APIDoc.{Doc.Endpoint, Documenter.Helper}

  defmacro __using__(_) do
    quote do
      unquote(Helper.register())

      @before_compile APIDoc.PhoenixRouterDocumenter
    end
  end

  defmacro __before_compile__(env) do
    doc =
      env.module
      |> Module.get_attribute(:phoenix_routes)
      |> Enum.sort_by(& &1.line)
      |> document(
        Module.get_attribute(env.module, :param),
        Module.get_attribute(env.module, :response)
      )
      |> :lists.reverse()

    quote do
      @doc false
      @spec __api_doc__ :: [APIDoc.Doc.Endpoint.t()]
      def __api_doc__ do
        unquote(Macro.escape(doc))
        |> Enum.map(fn
          %{lookup: {module, _, :forward}, fallback: fallback = %{path: path}} ->
            if {:__api_doc__, 0} in module.__info__(:functions) do
              Enum.map(
                module.__api_doc__,
                fn e = %Endpoint{path: p} -> %{e | path: path ++ p} end
              )
            else
              fallback
            end

          %{lookup: {module, name, _}, fallback: fallback} ->
            if {:__controller_doc__, 0} in module.__info__(:functions) do
              case Map.fetch(module.__controller_doc__(), name) do
                {:ok, doc} -> %{doc | method: fallback.method, path: fallback.path}
                _ -> fallback
              end
            else
              fallback
            end
        end)
        |> List.flatten()
      end
    end
  end

  defp document(routes, params, response, acc \\ [])

  defp document([], _params, _responses, acc), do: acc

  defp document([%{verb: :*, kind: kind} | routes], params, responses, acc) when kind != :forward,
    do: document(routes, params, responses, acc)

  defp document([route | routes], params, responses, acc) do
    params_g = Enum.group_by(params, &(&1.line < route.line))
    responses_g = Enum.group_by(responses, &(&1.line < route.line))

    document(routes, params_g[false] || [], responses_g[false] || [], [
      %{
        lookup: {route.plug, route.opts, route.kind},
        fallback: %Endpoint{
          id: route.path,
          tags: [],
          summary: nil,
          method: route.verb,
          path: parse_path(route.path),
          description: nil,
          parameters: params_g[true] || [],
          responses: responses_g[true] || []
        }
      }
      | acc
    ])
  end

  defp parse_path(path) do
    path
    |> String.trim_leading("/")
    |> String.split("/")
    |> Enum.map(fn
      "*" <> var -> String.to_atom(var)
      ":" <> var -> String.to_atom(var)
      var -> var
    end)
  end
end
