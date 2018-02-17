defmodule APIDoc.Doc.Server do
  @moduledoc ~S"""
  Server URL and description for .

  ## Examples

  Only URL:
  ```
  %Server{url: "https://prod.example.com"}
  ```

  URL and description:
  ```
  %Server{
    url:  "https://prod.example.com",
    description: "Production example server"
  }
  ```
  """

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          url: String.t(),
          description: String.t() | nil
        }

  @enforce_keys [:url]
  defstruct [
    :url,
    description: nil
  ]
end
