defmodule Movement.Languages.Compiler.Repos do
  def exec(dir, _) do
    Enum.map_reduce(list_dir(dir), [], fn(repo, acc) ->
      key = List.to_atom(repo)
      {langs, paths} = langs(Path.join(dir, repo))
      {{key, langs}, paths ++ acc}
    end)
  end

  def to_set(variants) do
    Enum.reduce(variants, HashSet.new, fn({_variant, repos}, acc) ->
      Enum.reduce(repos, acc, fn({repo, _}, acc) ->
        Set.put(acc, repo)
      end)
    end)
  end

  defp langs(dir) do
    Enum.map_reduce(list_dir(dir, &File.regular?/1), [], fn(lang, acc) ->
      path = Path.join(dir, lang)
      key = lang |> Path.basename(".json") |> String.to_atom
      pages = path |> parse |> Enum.map(&expand_page/1)
      {{key, pages}, [path | acc]}
    end)
  end

  defp list_dir(dir, filter \\ &File.dir?/1) do
    {:ok, items} = :file.list_dir(dir)
    Enum.filter(items, fn
      ("." <> _) ->
        false
      (file) ->
        filter.(Path.join(dir, file))
    end)
  end

  defp parse(file) do
    file
    |> File.read!
    |> Poison.decode!
  rescue
    e ->
      throw "Error in #{file}: #{e.message}"
  end

  defp expand_page({page, items}) do
    {String.to_atom(page), items |> Enum.map(&expand_item/1)}
  end

  defp expand_item({key, entries = %{"default" => _}}) do
    {String.to_atom(key), entries |> Enum.map(&expand_entry/1)}
  end
  defp expand_item({key, entry}) when is_binary(entry) do
    {String.to_atom(key), [{:default, entry}]}
  end
  defp expand_item({key, entries}) when is_map(entries) do
    if is_plural?(entries) do
      {String.to_atom(key), [{:default, entries}]}
    else
      entries = entries |> Enum.map(&expand_entry/1)
      case :lists.keysort(1, entries) do
        [] ->
          {String.to_atom(key), []}
        [{_, default} | _] ->
          {String.to_atom(key), [{:default, default} | entries]}
      end
    end
  end

  defp expand_entry({variant, entry}) when is_binary(entry) do
    {String.to_atom(variant), entry}
  end
  defp expand_entry({variant, entry}) when is_map(entry) do
    if is_plural?(entry) do
      {String.to_atom(variant), entry}
    else
      throw "Invalid entry #{inspect(entry)}"
    end
  end

  defp is_plural?(entry) do
    Enum.any?(entry, &check_plural_key/1)
  end

  defp check_plural_key({key, _}) do
    key in ["zero", "one", "two", "few", "many", "other"] || String.to_integer(key)
  rescue
    _ ->
      false
  end
end