defmodule APIDoc.PlugRouterDocumenter do
  @moduledoc ~S"""
  """

  require Logger
  alias APIDoc.{Doc.Router, Documenter.Helper}

  @http_methods ~W(GET POST PUT PATCH DELETE)

  defmacro __using__(_) do
    quote do
      unquote(Helper.register())

      @on_definition {APIDoc.PlugRouterDocumenter, :on_def}
      @before_compile APIDoc.PlugRouterDocumenter
    end
  end

  @doc false
  @spec on_def(term, :def | :defp, atom, term, term, term) :: term
  # credo:disable-for-next-line
  def on_def(env, :defp, :do_match, [{:conn, _, Plug.Router}, method, path, _], _guards, _body) do
    cond do
      (api = Module.delete_attribute(env.module, :api)) && method in @http_methods ->
        atom_method = method |> String.downcase() |> String.to_existing_atom()
        Helper.generate_api_doc(env.module, api, atom_method, path)

      (forward = Module.get_attribute(env.module, :plug_forward_target)) && is_list(path) ->
        generate_forward(env.module, forward, path)

      Module.delete_attribute(env.module, :api) == false ->
        :ignore

      :undocumented ->
        Logger.warn(fn -> warn_undocumented(env.module, method, path) end)
    end
  end

  # credo:disable-for-next-line
  def on_def(_env, _type, _name, _args, _guards, _body), do: :ignore

  defp warn_undocumented(module, method, path) do
    safe_module = module |> Module.split() |> Enum.join(".")
    safe_method = if is_binary(method), do: method, else: "*"

    # credo:disable-for-next-line
    safe_path =
      if is_tuple(path) do
        ""
      else
        path
        |> Enum.map(&if(is_tuple(&1), do: elem(&1, 0), else: &1))
        |> Enum.map(&to_string/1)
        |> Enum.join("/")
      end

    "APIDoc: #{safe_method} /#{safe_path} in #{safe_module} is undocumented, please document or use `@api false`."
  end

  defp generate_forward(module, forward, path) do
    cond do
      Module.delete_attribute(module, :api) == false ->
        :ignore

      {:__api_doc__, 0} in forward.__info__(:functions) ->
        last = List.last(path)

        if is_tuple(last) && elem(last, 0) == :| do
          Module.put_attribute(module, :generated_api_doc, %{
            to: forward,
            description:
              if(doc = Module.delete_attribute(module, :doc), do: elem(doc, 1) || nil, else: nil),
            path:
              Enum.map(path, fn
                {field, _, nil} -> field
                {:|, _, [{field, _, nil} | _]} -> field
                {:|, _, [step | _]} -> step
                step -> step
              end),
            security: Module.delete_attribute(module, :security) || []
          })
        end

      :undocumented ->
        Logger.warn(fn ->
          safe_module = module |> Module.split() |> Enum.join(".")
          safe_forward = forward |> Module.split() |> Enum.join(".")

          "APIDoc: #{safe_module} forwards to #{safe_forward}, but #{safe_forward} is not documented."
        end)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @doc false
      @spec __api_doc__ :: [APIDoc.Doc.Endpoint.t()]
      def __api_doc__ do
        Enum.map(@generated_api_doc, fn
          endpoint = %{to: to} ->
            struct(Router, endpoint |> Map.delete(:to) |> Map.put(:endpoints, to.__api_doc__()))

          endpoint ->
            endpoint
        end)
      end
    end
  end
end
