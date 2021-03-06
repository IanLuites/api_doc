defmodule APIDoc.Doc.Document do
  @moduledoc ~S"""
  Main API documentation structure.
  """

  alias APIDoc.Doc.{
    Info,
    Schema,
    Security,
    Server
  }

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          info: Info.t(),
          servers: [Server.t()],
          schemas: [Schema.t()],
          security: [Security.t()],
          endpoints: list
        }

  @enforce_keys [
    :info,
    :servers,
    :schemas,
    :security,
    :endpoints
  ]
  defstruct @enforce_keys
end
