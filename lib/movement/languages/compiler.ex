defmodule Movement.Languages.Compiler do
  alias Movement.Languages.Compiler.Repos
  alias Movement.Languages.Compiler.Languages
  alias Movement.Languages.Compiler.Variants
  alias Movement.Languages.Compiler.Codegen

  defmacro compile(opts \\ %{}) do
    {repos, files} = Repos.exec(dir(opts), opts)
    repos
    |> Languages.exec(opts)
    |> Variants.exec(opts)
    |> Codegen.exec(files, opts)
  end

  defp dir(%{dir: dir}) do
    dir
  end
  defp dir(_) do
    :code.which(__MODULE__)
    |> Path.dirname
    |> Path.dirname
    |> Path.join("priv")
  end
end
