defmodule APIDoc.Format.APIBlueprint do
  @moduledoc ~S"""
  """

  def format(document) do
    """
    Format: 1A
    #{document.servers |> Enum.map(&("HOST: " <> &1.url)) |> Enum.join("\n")}

    # #{document.info.name}

    #{document.info.description}

    #{document.endpoints |> Enum.map(&paths(&1, document)) |> Enum.join("\n")}
    """
    |> String.replace(~r/\n[\r\ \t]*\n[\r\ \t]*\n/, "\n\n")
  end

  defp paths(data, document, pre \\ "")

  defp paths(%{path: path, endpoints: endpoints}, document, pre) do
    path = pre <> format_path(path)

    endpoints |> Enum.sort_by(&Enum.count(&1.path)) |> Enum.map(&paths(&1, document, path))
    |> Enum.join("\n")
  end

  defp paths(data = %{id: api}, document, pre) do
    path = pre <> format_path(data.path)

    method = data.method |> to_string() |> String.upcase()

    """
    ## [#{path}]

    ### #{data.id} [#{method}]

    #{Map.get(data, :description, data.summary)}

    #{data.parameters |> Enum.map(&param/1) |> Enum.join("\n")}

    #{
      data.responses |> Enum.sort_by(& &1.status) |> Enum.map(&endpoint(&1, document))
      |> Enum.join("\n")
    }
    """
  end

  defp format_path([]), do: ""

  defp format_path(path) do
    "/" <>
      (path
       |> Enum.map(&if(is_atom(&1), do: "{#{&1}}", else: &1))
       |> Enum.join("/"))
  end

  defp param(%{name: name, type: type, description: description, example: example}) do
    example = if example, do: ": #{inspect(example)}", else: ""
    "+ #{name}#{example} (#{type}) - #{description}"
  end

  defp endpoint(%{status: status, content: content}, document) do
    content
    |> Enum.map(fn {type, data} -> endpoint(status, type, data, document) end)
    |> Enum.join("\n")
  end

  defp endpoint(status, :"application/json", data, document) do
    example =
      document.schemas
      |> Enum.find(&(Macro.to_string(&1.name) == data))
      |> Map.get(:example)
      |> Poison.encode!(pretty: true)
      |> String.split("\n")
      |> Enum.map(&("        " <> &1))
      |> Enum.join("\n")

    "+ Response #{status} (application/json)\n\n#{example}\n"
  end

  defp endpoint(status, type, data, _document) do
    "+ Response #{status} (#{type})"
  end
end
