defmodule Sprechen do
  defmacro __using__(opts) do
    files = (opts[:dir] <> "/**/*.json")
    |> Path.wildcard()

    quote do
      require Sprechen.Compiler
      Sprechen.Compiler.compile(unquote(files))
    end
  end
end
