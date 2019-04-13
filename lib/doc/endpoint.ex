defmodule APIDoc.Doc.Endpoint do
  @moduledoc ~S"""

  """
  alias APIDoc.Doc.{Param, Response}

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          method: :get | :post | :put | :patch | :delete,
          path: [String.t() | atom],
          id: String.t(),
          summary: String.t(),
          description: String.t() | nil,
          parameters: [Param.t()],
          responses: [Response.t()],
          tags: [String.t()],
          security: [atom | [atom]]
        }

  @enforce_keys [
    :method,
    :path,
    :id,
    :summary
  ]
  defstruct [
    :method,
    :path,
    :id,
    :summary,
    description: nil,
    parameters: [],
    responses: [],
    tags: [],
    security: []
  ]
end
