defmodule APIDoc.Documenter.Helper do
  @moduledoc false
  alias APIDoc.Doc.{Endpoint, Param, Response}

  @doc false
  @spec register :: term
  def register do
    quote do
      @doc false
      Module.register_attribute(__MODULE__, :generated_api_doc, accumulate: true, persist: false)
      Module.register_attribute(__MODULE__, :api, accumulate: false, persist: false)
      Module.register_attribute(__MODULE__, :tags, accumulate: false, persist: false)
      Module.register_attribute(__MODULE__, :summary, accumulate: false, persist: false)
      Module.register_attribute(__MODULE__, :param, accumulate: true, persist: false)
      Module.register_attribute(__MODULE__, :response, accumulate: true, persist: false)
      Module.register_attribute(__MODULE__, :security, accumulate: true, persist: false)

      require unquote(__MODULE__)
      import unquote(__MODULE__), only: [response: 3, param: 3, param: 4]
    end
  end

  @doc false
  @spec generate_api_doc(module, term, atom, [String.t() | atom]) :: :ok
  def generate_api_doc(module, api, method, path) do
    Module.put_attribute(module, :generated_api_doc, %Endpoint{
      id: api,
      tags: Module.delete_attribute(module, :tags) || [],
      summary: Module.delete_attribute(module, :summary),
      method: method,
      path: Enum.map(path, &if(is_tuple(&1), do: elem(&1, 0), else: &1)),
      description:
        if(doc = Module.get_attribute(module, :doc), do: elem(doc, 1) || nil, else: nil),
      parameters: Module.delete_attribute(module, :param) || [],
      responses: Module.delete_attribute(module, :response) || [],
      security: Module.delete_attribute(module, :security) || []
    })
  end

  defmacro response(status, description, content) do
    quote do
      @response %Response{
        line: unquote(__CALLER__.line),
        status: unquote(status),
        description: unquote(description),
        content: unquote(content)
      }
    end
  end

  defmacro param(name, type, description, opts \\ []) do
    quote do
      @param %Param{
        line: unquote(__CALLER__.line),
        name: unquote(name),
        type: unquote(type),
        description: unquote(description),
        required: unquote(opts[:required] || false),
        schema: unquote(opts[:schema])
      }
    end
  end
end
