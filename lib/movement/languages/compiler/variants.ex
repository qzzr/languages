defmodule Movement.Languages.Compiler.Variants do
  def exec(repos, _) do
    repos
    |> gather_variants
    |> Enum.map(&(expand_variant(&1, repos)))
  end

  def to_set(variants) do
    Enum.reduce(variants, HashSet.new, fn({variant, _}, acc) ->
      Set.put(acc, variant)
    end)
  end

  defp gather_variants(repos) do
    Enum.reduce(repos, HashSet.new, fn({_repo, langs}, acc) ->
      Enum.reduce(langs, acc, fn({_lang, pages}, acc) ->
        Enum.reduce(pages, acc, fn({_page, entries}, acc) ->
          Enum.reduce(entries, acc, fn({_entry, variants}, acc) ->
            Enum.reduce(variants, acc, fn({variant, _}, acc) ->
              Set.put(acc, variant)
            end)
          end)
        end)
      end)
    end)
  end

  defp expand_variant(variant, repos) do
    {variant, Enum.map(repos, fn({repo, langs}) ->
      {repo, Enum.map(langs, fn({lang, pages}) ->
        {lang, Enum.map(pages, fn({page, entries}) ->
          {page, Enum.map(entries, fn({entry, variants}) ->
            {entry, Dict.get(variants, variant) || Dict.get(variants, :default)}
          end)}
        end)}
      end)}
    end)}
  end
end