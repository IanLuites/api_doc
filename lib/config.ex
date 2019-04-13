defmodule APIDoc.Config do
  def document do
    Application.get_env(:api_doc, :document) || raise "Document not configured."
  end

  def directory(type) do
    Application.get_env(:api_doc, :directories, [])[type] ||
      raise "#{type} directory not configured."
  end
end
