locals_without_parens = [
  server: 1,
  server: 2,
  schema: 2,
  schema: 3
]

[
  inputs: ["mix.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  export: [
    locals_without_parens: locals_without_parens
  ]
]
