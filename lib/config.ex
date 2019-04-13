defmodule APIDoc.Config do
  @moduledoc false

  @doc false
  @spec document :: module | no_return
  def document do
    Application.get_env(:api_doc, :document) || raise "Document not configured."
  end

  @doc false
  @spec directory(atom) :: String.t() | no_return
  def directory(type) do
    Application.get_env(:api_doc, :directories, [])[type] ||
      raise "#{type} directory not configured."
  end
end
