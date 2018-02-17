defmodule APIDoc.Doc.Schema do
  @moduledoc ~S"""
  A schema definition for use as in and output type.
  """

  @typedoc ~S"""
  The schema type.
  """
  @type type ::
          :integer
          | :string
          | :object
          | :array

  @typedoc ~S"""
  The format for types that have different formats.

  Example: `:int32` for `:integer`s.
  """
  @type format ::
          :int32
          | :int64

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          name: atom,
          type: type,
          format: format | nil,
          required: list(atom) | nil,
          properties: map | nil,
          example: any,
          minimum: integer | nil,
          maximum: integer | nil,
          items: map
        }

  @enforce_keys [:name, :type]
  defstruct [
    :name,
    :type,
    format: nil,
    required: nil,
    properties: nil,
    example: nil,
    minimum: nil,
    maximum: nil,
    items: nil
  ]
end
