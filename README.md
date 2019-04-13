# API Doc

API documentation generator for Elixir.

## Installation

The package can be installed by adding `api_doc`
to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:api_doc, "~> 0.0.1"}
  ]
end
```

Documentation can be found at
[https://hexdocs.pm/api_doc](https://hexdocs.pm/api_doc).

## Upcoming Features

Upcoming and in progress features:

  * [X] Basic documentation setup.
  * [X] Plug.Router documentation.
  * [X] Warn on forwards to undocumented routers.
  * [ ] Warn for undocumented endpoints.
  * [ ] Warn undocumented path variable.
  * [ ] @api false to disable undocumented warnings.
  * [ ] Add default response[s].
  * [ ] Add schemas on different levels.
  * [ ] Basic configuration.
  * [ ] Cleanup documenters and improve documentation.

Output formats:
  * [ ] [OpenAPI 3.0](https://github.com/OAI/OpenAPI-Specification)
  * [ ] [API Blueprint](https://apiblueprint.org/documentation/specification.html)
  * [ ] [Postman Collection](https://www.getpostman.com/collection)

## License

_API Doc_ source code is released under [the MIT License](LICENSE).
Check [LICENSE](LICENSE) file for more information.
