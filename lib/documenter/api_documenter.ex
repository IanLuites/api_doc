defmodule APIDoc.APIDocumenter do
  @moduledoc ~S"""
  API Documenter.

  Documents the main entry of the API.

  The following annotations can be set:

    - `@api` (string) name of the API.
    - `@vsn` (string) version of the API.
    - `@moduledoc` (string) API description. Supports markdown.

  The following macros can be used for documenting:

    - `schema/2`, `schema/3`: Adds data schemas to the documentation.
    - `server/1`, `server/2`: Add possible servers to the documentation.
  """
  alias APIDoc.Doc.Schema
  alias APIDoc.Doc.Server
  alias Mix.Project

  @doc @moduledoc
  defmacro __using__(opts \\ []) do
    quote do
      Module.register_attribute(__MODULE__, :api, accumulate: false, persist: false)
      Module.register_attribute(__MODULE__, :server, accumulate: true, persist: false)
      Module.register_attribute(__MODULE__, :schema, accumulate: true, persist: false)

      require APIDoc.APIDocumenter
      import APIDoc.APIDocumenter, only: [server: 1, server: 2, schema: 2, schema: 3]
      @before_compile APIDoc.APIDocumenter
      @router unquote(opts[:router])
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    name = Module.get_attribute(env.module, :api) || "API Documentation"
    version = Module.get_attribute(env.module, :vsn) || Project.config()[:version]
    servers = Module.get_attribute(env.module, :server) || []
    schemas = Module.get_attribute(env.module, :schema) || []

    quote do
      @doc ~S"""
      Format the document with a given formatter.

      Uses `APIDoc.Format.OpenAPI3` by default.
      """
      @spec format(atom) :: String.t()
      def format(formatter \\ APIDoc.YAML), do: formatter.format(__document__())

      @doc false
      @spec __document__ :: map
      def __document__ do
        %APIDoc.Doc.Document{
          info: %APIDoc.Doc.Info{
            name: unquote(name),
            version: unquote(version),
            description: @moduledoc
          },
          servers: unquote(Macro.escape(servers)),
          schemas: unquote(Macro.escape(schemas)),
          endpoints: @router.__api_doc__()
        }
      end
    end
  end

  @doc ~S"""
  Add server to documentation.

  ## Examples

  Only url:
  ```
  server "https://prod.example.com"
  server "https://stage.example.com"
  ```

  Url and description:
  ```
  server "https://prod.example.com", "Production example server"
  server "https://stage.example.com", "Staging example server"
  ```
  """
  @spec server(String.t(), String.t() | nil) :: term
  defmacro server(url, description \\ nil) do
    quote do
      @server %Server{
        url: unquote(url),
        description: unquote(description)
      }
    end
  end

  @doc ~S"""
  Add schema to documentation.

  The `name` and `type` are always required.
  For additional optional fields see: `APIDoc.Doc.Schema`.

  ## Examples

  Just name and type:
  ```
  schema Name, :string
  schema Age, :integer
  ```

  Additional options:
  ```
  schema Name, :string,
    example: "Bob"

  schema Age, :integer,
    format: :int32,
    example: 34,
    minimum: 1,
    maximum: 150
  ```
  """
  @spec schema(atom, Schema.type(), Keyword.t()) :: term
  defmacro schema(name, type, opts \\ []) do
    quote do
      @schema %Schema{
        name: unquote(Macro.expand(name, __CALLER__)),
        type: unquote(type),
        format: unquote(opts[:format]),
        required: unquote(opts[:required]),
        properties: unquote(opts[:properties]),
        example: unquote(opts[:example]),
        minimum: unquote(opts[:minimum]),
        maximum: unquote(opts[:maximum]),
        items: unquote(opts[:items])
      }
    end
  end
end
