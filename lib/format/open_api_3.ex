defmodule APIDoc.Format.OpenAPI3 do
  @moduledoc ~S"""
  """

  @doc @moduledoc
  @spec format(APIDoc.Document.t()) :: String.t()
  def format(document) do
    paths = document.endpoints |> Enum.map(&elem(paths(&1), 1)) |> Enum.join("\n")
    schemas = document.schemas |> Enum.map(&format_schema/1) |> Enum.join("\n")
    security_schemes = document.security |> Enum.map(&format_security/1) |> Enum.join("\n")

    """
    openapi: 3.0.0
    info:
    #{info(document.info)}
    servers:
    #{servers(document.servers)}
    paths:
    #{paths}
    components:
      schemas:
    #{schemas}
      securitySchemes:
    #{security_schemes}
    """
    |> String.replace(~r/\n{2,}/, "\n")
  end

  defp info(info) do
    contact =
      if info.contact do
        """
          contact:
            name: #{info.contact.name}
            email: #{info.contact.email}
        """
      else
        ""
      end

    """
      title: #{info.name}
      description: |
        #{info.description |> String.split("\n") |> Enum.join("    \n")}
      version: #{info.version}
    #{contact}
    """
  end

  defp servers(servers) do
    servers
    |> Enum.map(
      &"""
        - url: #{&1.url}
          description: #{&1.description}
      """
    )
    |> Enum.join("\n")
  end

  defp paths(data, pre \\ "", security \\ [], prev_path \\ "")

  defp paths(%{path: path, endpoints: endpoints, security: secure}, pre, security, prev_path) do
    path = pre <> format_path(path)
    security = secure ++ security

    endpoints
    |> Enum.sort_by(&Enum.count(&1.path))
    |> Enum.reduce({prev_path, ""}, fn e, {p, doc} ->
      {pn, d} = paths(e, path, security, p)
      {pn, doc <> "\n" <> d}
    end)
  end

  defp paths(data = %{id: api, security: secure}, pre, security, prev_path) do
    path = pre <> format_path(data.path)
    security = secure ++ security

    {path,
     """
     #{if path != prev_path, do: "  " <> path <> ":", else: ""}
         #{data.method}:
           operationId: #{api}
     #{format_summary(data.summary)}
     #{format_description(data.description)}
     #{format_tags(data.tags)}
     #{format_params(data.parameters)}
           responses:
     #{data.responses |> Enum.map(&format_response/1) |> Enum.join("")}
           security:
     #{security |> Enum.map(&format_security_use/1) |> Enum.join("\n")}
     """}
  end

  defp format_security_use([secure | security]) do
    [
      "        - #{Macro.to_string(secure)}: []"
      | security |> Enum.map(&"          #{Macro.to_string(&1)}: []")
    ]
    |> Enum.join("\n")
  end

  defp format_security_use(secure) do
    "        - #{Macro.to_string(secure)}: []"
  end

  defp format_description(nil), do: ""

  defp format_description(description) do
    "      description: |\n        " <>
      (description |> String.split("\n") |> Enum.join("\n        "))
  end

  defp format_summary(nil), do: ""
  defp format_summary(summary), do: "      summary: " <> summary

  defp format_tags([]), do: ""

  defp format_tags(tags),
    do: "      tags:\n" <> (tags |> Enum.map(&("        - " <> &1)) |> Enum.join("\n"))

  defp format_path([]), do: ""

  defp format_path(path) do
    "/" <>
      (path
       |> Enum.map(&if(is_atom(&1), do: "{#{&1}}", else: &1))
       |> Enum.join("/"))
  end

  defp format_params([]), do: ""

  defp format_params(params),
    do: "      parameters:\n" <> (params |> Enum.map(&create_param/1) |> Enum.join(""))

  defp create_param(%{
         name: name,
         type: type,
         description: description,
         required: required,
         schema: schema
       }) do
    schema =
      schema
      |> Kernel.||(%{type: "string"})
      |> Enum.map(fn {k, v} -> "            #{k}: #{v}" end)
      |> Enum.join("\n")

    """
            - name: #{name}
              in: #{type}
              description: #{description}
              required: #{if required, do: "true", else: "false"}
              schema:
    #{schema}
    """
  end

  defp format_response(%{
         status: status,
         description: description,
         content: content
       }) do
    status = if status == :default, do: "default", else: "'#{status}'"

    responses =
      content
      |> Enum.map(fn {response, type} ->
        """
                    #{response}:
                      schema:
                        $ref: "#/components/schemas/#{type}"
        """
      end)
      |> Enum.join("\n")

    """
            #{status}:
              description: #{description}
              content:
    #{responses}
    """
  end

  defp format_schema(schema = %{type: :object}) do
    name = schema.name |> to_string() |> String.trim_leading("Elixir.")

    """
        #{name}:
          required:
    #{schema.required |> Enum.map(&"        - #{&1}") |> Enum.join("\n")}
          properties:
    #{
      schema.properties
      |> Enum.map(&format_property(&1, schema.example || %{}))
      |> Enum.join("\n")
    }
    """
  end

  defp format_schema(schema) do
    name = schema.name |> to_string() |> String.trim_leading("Elixir.")

    example = if schema.example, do: "      example: #{inspect(schema.example)}", else: ""
    items = if schema.items, do: "      items:\n        type: #{schema.items.type}", else: ""

    """
        #{name}:
          type: #{schema.type}
    #{example}
    #{items}
    """
  end

  defp format_property({property, data}, example) do
    example =
      if Map.get(example, property),
        do: "          example: #{inspect(Map.get(example, property))}",
        else: ""

    """
            #{property}:
              type: #{data.type}
    #{example}
    """
  end

  defp format_security({id, schema}) do
    name = id |> to_string() |> String.trim_leading("Elixir.")

    description =
      if schema.description, do: "      description: #{inspect(schema.description)}", else: ""

    """
        #{name}:
          type: #{schema.type}
          in: #{schema.in}
          name: #{schema.name}
    #{description}
    """
  end
end
