defmodule APIDoc.Doc.Response do
  @moduledoc ~S"""

  """

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          status: pos_integer | :default,
          description: String.t(),
          content: map
        }

  @enforce_keys [
    :status,
    :description,
    :content
  ]
  defstruct @enforce_keys
end
