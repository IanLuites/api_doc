defmodule APIDoc.Format.HTML do
  @moduledoc ~S"""
  """

  def format(document) do
    shins = APIDoc.Config.directory(:shins)
    docs = APIDoc.Format.OpenAPI3.format(document)
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
