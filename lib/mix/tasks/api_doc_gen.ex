defmodule Mix.Tasks.Api.Doc.Gen do
  use Mix.Task

  @shortdoc "Generate API documentation (use `--help` for options)"
  @moduledoc @shortdoc

  @options %{
    "-o" => :output,
    "--output" => :output,
    "-f" => :format,
    "--format" => :format
  }

  @formats %{
    "openapi" => APIDoc.Format.OpenAPI3,
    "openapi3" => APIDoc.Format.OpenAPI3,
    "blueprint" => APIDoc.Format.APIBlueprint,
    "apiblueprint" => APIDoc.Format.APIBlueprint,
    "postman" => APIDoc.Format.PostmanCollection,
    "postman2" => APIDoc.Format.PostmanCollection,
    "postman2.1" => APIDoc.Format.PostmanCollection,
    "html" => APIDoc.Format.HTML
  }

  @doc false
  def run(argv) do
    Mix.Task.run("compile")

    options =
      [
        output: "stdout",
        format: "openapi3"
      ]
      |> Keyword.merge(parse_arguments(argv))
      |> Enum.map(&validate_option/1)

    data = APIDoc.Config.document().format(options[:format])

    if options[:output] == :stdout do
      IO.puts(data)
    else
      File.write!(options[:output], data)
    end
  end

  defp parse_arguments(arg, opts \\ [])
  defp parse_arguments([], opts), do: opts

  defp parse_arguments([setting], opts) do
    [k, v] = String.split(setting, "=")
    [{parse_option(k), v} | opts]
  end

  defp parse_arguments([option, value | tail], opts) do
    with [k, v] <- String.split(option, "=") do
      parse_arguments([value | tail], [{parse_option(k), v} | opts])
    else
      _ -> parse_arguments(tail, [{parse_option(option), value} | opts])
    end
  end

  defp parse_option(option), do: @options[option] || raise("Invalid option: #{option}.")

  defp validate_option({:output, output}) do
    if output == "stdout" do
      {:output, :stdout}
    else
      {:output, :stdout}
    end
  end

  defp validate_option({:format, format}) do
    {
      :format,
      Map.get(@formats, String.downcase(format)) || raise("Invalid output format: #{format}.")
    }
  end
end
