defmodule APIDoc.Doc.Contact do
  @moduledoc ~S"""
  Contact information.

  ## Example

  ```
  %Contact{
    name: "Bob Franken",
    email: "bob@example.com",
    url: "http://example.com/bob"
  }
  ```
  """

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          name: String.t(),
          email: String.t(),
          url: String.t()
        }

  @enforce_keys [:name, :email]
  defstruct @enforce_keys ++ [url: nil]
end
