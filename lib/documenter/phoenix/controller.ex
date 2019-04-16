defmodule APIDoc.PhoenixControllerDocumenter do
  @moduledoc ~S"""
  """

  alias APIDoc.{Doc.Endpoint, Documenter.Helper}

  defmacro __using__(_) do
    quote do
      unquote(Helper.register())

      @on_definition {APIDoc.PhoenixControllerDocumenter, :on_def}
      @before_compile APIDoc.PhoenixControllerDocumenter
    end
  end

  @doc false
  @spec on_def(term, :def | :defp, atom, term, term, term) :: term
  # credo:disable-for-next-line
  def on_def(env, :def, name, [_, _], _guards, _body) do
    if api = Module.delete_attribute(env.module, :api) do
      Helper.generate_api_doc(env.module, api, name, ["?"])
    end
  end

  # credo:disable-for-next-line
  def on_def(_env, _type, _name, _args, _guards, _body), do: :ignore

  defmacro __before_compile__(env) do
    doc =
      env.module
      |> Module.delete_attribute(:generated_api_doc)
      |> Map.new(fn e = %Endpoint{method: m} -> {m, %{e | method: :"?"}} end)

    quote do
      @doc false
      @spec __controller_doc__ :: %{atom => APIDoc.Doc.Endpoint.t()}
      def __controller_doc__, do: unquote(Macro.escape(doc))
    end
  end
end
