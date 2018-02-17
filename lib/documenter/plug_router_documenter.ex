defmodule APIDoc.PlugRouterDocumenter do
  @moduledoc ~S"""
  """

  require Logger
  alias APIDoc.Doc.{Endpoint, Param, Response, Router}

  @http_methods ~W(GET POST PUT PATCH DELETE)

  defmacro __using__(_) do
    quote do
      @doc false
      Module.register_attribute(__MODULE__, :generated_api_doc, accumulate: true, persist: false)
      Module.register_attribute(__MODULE__, :api, accumulate: false, persist: false)
      Module.register_attribute(__MODULE__, :tags, accumulate: false, persist: false)
      Module.register_attribute(__MODULE__, :summary, accumulate: false, persist: false)
      Module.register_attribute(__MODULE__, :param, accumulate: true, persist: false)
      Module.register_attribute(__MODULE__, :response, accumulate: true, persist: false)

      require APIDoc.PlugRouterDocumenter
      import APIDoc.PlugRouterDocumenter, only: [response: 3, param: 3, param: 4]
      @on_definition {APIDoc.PlugRouterDocumenter, :on_def}
      @before_compile APIDoc.PlugRouterDocumenter
    end
  end

  # credo:disable-for-next-line
  def on_def(env, :defp, :do_match, [{:conn, _, Plug.Router}, method, path, _], _guards, _body) do
    cond do
      (api = Module.delete_attribute(env.module, :api)) && method in @http_methods ->
        generate_api_doc(env.module, api, method, path)

      (forward = Module.get_attribute(env.module, :plug_forward_target)) && is_list(path) ->
        generate_forward(env.module, forward, path)

      :otherwise ->
        :ignore
    end
  end

  # credo:disable-for-next-line
  def on_def(_env, _type, _name, _args, _guards, _body), do: :ignore

  defp generate_api_doc(module, api, method, path) do
    atom_method = method |> String.downcase() |> String.to_existing_atom()

    Module.put_attribute(module, :generated_api_doc, %Endpoint{
      id: api,
      tags: Module.delete_attribute(module, :tags) || [],
      summary: Module.delete_attribute(module, :summary),
      method: atom_method,
      path: Enum.map(path, &if(is_tuple(&1), do: elem(&1, 0), else: &1)),
      description:
        if(doc = Module.delete_attribute(module, :doc), do: elem(doc, 1) || nil, else: nil),
      parameters: Module.delete_attribute(module, :param) || [],
      responses: Module.delete_attribute(module, :response) || []
    })
  end

  defp generate_forward(module, forward, path) do
    if {:__api_doc__, 0} in forward.__info__(:functions) do
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
            end)
        })
      end
    else
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

  defmacro response(status, description, content) do
    quote do
      @response %Response{
        status: unquote(status),
        description: unquote(description),
        content: unquote(content)
      }
    end
  end

  defmacro param(name, type, description, opts \\ []) do
    quote do
      @param %Param{
        name: unquote(name),
        type: unquote(type),
        description: unquote(description),
        required: unquote(opts[:required] || false),
        schema: unquote(opts[:schema])
      }
    end
  end
end
