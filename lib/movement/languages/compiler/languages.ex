defmodule Movement.Languages.Compiler.Languages do
  require Logger

  def exec(repos, opts) do
    default = Dict.get(opts, :default_lang, :en)
    repos
    |> Enum.map(&(expand_variant(&1, default)))
  end

  def to_set(variants) do
    Enum.reduce(variants, HashSet.new, fn({_variant, repos}, acc) ->
      Enum.reduce(repos, acc, fn({_repo, langs}, acc) ->
        Enum.reduce(langs, acc, fn
          ({{:_, _}, _}, acc) ->
            acc
          ({lang, _}, acc) ->
            Set.put(acc, lang)
        end)
      end)
    end)
  end

  defp expand_variant({repo, langs}, default) do
    default_pages = Dict.get(langs, default)
    {repo, Enum.map(langs, fn
      ({lang, pages}) when lang == default ->
        {lang, pages}
      ({lang, pages}) ->
        {lang, merge(lang, repo, pages, default_pages)}
    end) ++ [{{:_, default}, default_pages}]}
  end

  defp merge(lang, repo, pages, default_pages) do
    Enum.map(default_pages, fn({page, default_entries}) ->
      entries = Dict.get(pages, page, [])
      {page, Enum.map(default_entries, fn({entry, default_value}) ->
        value = Dict.get(entries, entry)
        if !value, do: Logger.warn("missing '#{repo}/#{lang}.json#/#{page}/#{entry}'")
        {entry, value || default_value}
      end)}
    end)
  end
end