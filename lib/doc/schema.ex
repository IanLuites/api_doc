defmodule APIDoc.Doc.Schema do
  @moduledoc ~S"""
  A schema definition for use as in and output type.
  """
  require Logger

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

  @doc false
  @spec validate!(t) :: :ok
  def validate!(schema) do
    with %{errors: errors, warnings: warnings} <- validate(schema) do
      name = Macro.to_string(schema.name)
      if errors != [], do: Enum.each(errors, &Logger.error("APIDoc: Schema '#{name}': #{&1}"))
      if warnings != [], do: Enum.each(warnings, &Logger.warn("APIDoc: Schema '#{name}': #{&1}"))
    end

    :ok
  end

  @doc false
  @spec validate(t) :: :ok | %{errors: [String.t()], warnings: [String.t()]}
  def validate(schema = %__MODULE__{type: type}) do
    validated =
      schema
      |> Map.from_struct()
      |> Enum.map(fn {k, v} -> validate_property(type, k, v) end)
      |> Enum.reject(&is_nil/1)
      |> Enum.group_by(&elem(&1, 0))

    if validated[:error] || validated[:warn] do
      %{
        errors: Enum.map(validated[:error] || [], &elem(&1, 1)),
        warnings: Enum.map(validated[:warn] || [], &elem(&1, 1))
      }
    else
      :ok
    end
  end

  @spec validate_property(type, atom, any) :: nil | {:error, String.t()} | {:warn, String.t()}
  # Integer
  defp validate_property(:integer, :format, nil),
    do: {:warn, "No format set for integer. Recommend setting `:int32` or `:int64`."}

  # Object
  defp validate_property(:object, :properties, nil), do: {:error, "No properties set for object."}

  defp validate_property(:object, :required, nil),
    do: {:error, "No required properties set for object. Recommend setting required fields."}

  # All
  defp validate_property(_type, :example, nil),
    do: {:warn, "No example supplied. Strongly recommend setting an example."}

  defp validate_property(_type, _property, _value), do: nil
end
