defmodule APIDoc.Doc.Router do
  @moduledoc ~S"""

  """
  alias APIDoc.Doc.{Endpoint, Security}

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          path: [String.t() | atom],
          endpoints: [t | Endpoint.t()],
          security: [atom | [atom]],
          description: String.t() | nil
        }

  @enforce_keys [
    :path,
    :endpoints
  ]
  defstruct [
    :path,
    :endpoints,
    security: [],
    description: nil
  ]
end
