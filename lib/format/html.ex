defmodule APIDoc.Format.HTML do
  @moduledoc ~S"""
  """

  alias APIDoc.{Config, Format.OpenAPI3}

  @doc @moduledoc
  @spec format(APIDoc.Document.t()) :: String.t()
  def format(document) do
    shins = Config.directory(:shins)
    docs = OpenAPI3.format(document)
    File.write("./test.yml", docs)

    System.cmd("widdershins", [
      "./test.yml",
      "-o",
      "#{shins}/source/index.html.md"
    ])

    System.cmd("node", ["shins.js", "--inline"], cd: "#{shins}/")
    File.read!("#{shins}/index.html")
  end
end
