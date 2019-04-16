defmodule APIDoc.Doc.Param do
  @moduledoc ~S"""

  """

  @type type :: :path | :query

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          name: String.t(),
          type: type,
          description: String.t(),
          required: boolean,
          schema: map,
          example: any,
          line: pos_integer
        }

  @enforce_keys [
    :name,
    :type,
    :description,
    :schema
  ]
  defstruct [
    :name,
    :type,
    :description,
    :schema,
    required: false,
    example: nil,
    line: 1
  ]
end
