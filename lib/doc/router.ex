defmodule APIDoc.Doc.Router do
  @moduledoc ~S"""

  """
  alias APIDoc.Doc.Endpoint

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          path: [String.t() | atom],
          endpoints: [t | Endpoint.t()],
          description: String.t() | nil
        }

  @enforce_keys [
    :path,
    :endpoints
  ]
  defstruct [
    :path,
    :endpoints,
    description: nil
  ]
end
