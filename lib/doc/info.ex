defmodule APIDoc.Doc.Info do
  @moduledoc ~S"""
  General API information.

  ## Example

  ```
  %Info{
    name: "Example API",
    version: "0.1.3",
    description: \"""
    Example API documentation.

    Supports _markdown_.
    \"""
  }
  ```
  """

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          name: String.t(),
          version: String.t(),
          description: String.t()
        }

  @enforce_keys [:name, :version, :description]
  defstruct @enforce_keys
end
