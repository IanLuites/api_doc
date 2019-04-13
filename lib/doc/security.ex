defmodule APIDoc.Doc.Security do
  @moduledoc ~S"""

  """

  @type type :: :apiKey | :http | :oauth2 | :openIdConnect

  @type location :: :query | :header | :cookie

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          name: String.t(),
          type: type,
          in: location,
          description: String.t() | nil
        }

  @enforce_keys [
    :name,
    :type,
    :in
  ]
  defstruct [
    :name,
    :type,
    :in,
    description: nil
  ]
end
