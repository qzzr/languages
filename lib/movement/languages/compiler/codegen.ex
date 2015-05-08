defmodule Movement.Languages.Compiler.Codegen do
  alias Movement.Languages.Compiler.Variants
  alias Movement.Languages.Compiler.Languages
  alias Movement.Languages.Compiler.Repos

  def exec(variants, files, _) do
    quote do
      unquote_splicing do
        Enum.map(files, fn(file) ->
          quote do
            @external_resource unquote(file)
          end
        end)
      end
      def variants do
        unquote(variants |> Variants.to_set |> set_to_list)
      end
      def repos do
        unquote(variants |> Repos.to_set |> set_to_list)
      end
      def languages do
        unquote(variants |> Languages.to_set |> set_to_list)
      end

      def lookup(variant, repo, locale, wildcard \\ true)
      def lookup(variant, repo, lang, wildcard) when is_binary(lang) do
        lookup(variant, repo, [lang], wildcard)
      end
      def lookup(variant, repo, [], true) do
        perform_lookup(variant, repo, :_)
      end
      def lookup(variant, repo, [], _) do
        nil
      end
      def lookup(variant, repo, [lang | rest], wildcard) do
        case parse(variant, repo, lang) do
          nil ->
            lookup(variant, repo, rest, wildcard)
          out ->
            out
        end
      end

      defp parse(variant, repo, <<compact :: size(2)-binary, "_", _ :: binary>> = lang) do
        scan(variant, repo, [lang, compact])
      end
      defp parse(variant, repo, <<compact :: size(3)-binary, "_", _ :: binary>> = lang) do
        scan(variant, repo, [lang, compact])
      end
      defp parse(variant, repo, <<compact :: size(2)-binary, "-", _ :: binary>> = lang) do
        scan(variant, repo, [lang, compact])
      end
      defp parse(variant, repo, <<compact :: size(3)-binary, "-", _ :: binary>> = lang) do
        scan(variant, repo, [lang, compact])
      end
      defp parse(variant, repo, lang) do
        perform_lookup(variant, repo, lang)
      end

      defp scan(_, _, []) do
        nil
      end
      defp scan(variant, repo, [lang | rest]) do
        case perform_lookup(variant, repo, lang) do
          nil ->
            scan(variant, repo, rest)
          out ->
            out
        end
      end

      unquote_splicing(Enum.map(variants, fn({variant, repos}) ->
        quote do
          unquote_splicing(Enum.map(repos, fn({repo, langs}) ->
            quote do
              unquote_splicing(Enum.map(langs, fn
                ({{:_, lang}, pages}) ->
                  quote do
                    defp perform_lookup(unquote(to_string(variant)), unquote(to_string(repo)), :_) do
                      {unquote(to_string(lang)), unquote(Macro.escape(pages_to_map(pages, lang)))}
                    end
                  end
                ({lang, pages}) ->
                  quote do
                    defp perform_lookup(unquote(to_string(variant)), unquote(to_string(repo)), unquote(to_string(lang)) = lang) do
                      {lang, unquote(Macro.escape(pages_to_map(pages, lang)))}
                    end
                  end
              end))
            end
          end))
        end
      end))
      defp perform_lookup(_, _, _) do
        nil
      end
    end
  end

  defp set_to_list(set) do
    Enum.map(set, &to_string/1)
  end

  defp pages_to_map(pages, lang) do
    map = Enum.map(pages, fn({page, entries}) ->
      {to_string(page), Enum.map(entries, fn({entry, value}) ->
        {to_string(entry), value}
      end) |> :maps.from_list}
    end) |> :maps.from_list

    Dict.put(map, "_info", %{"locale" => to_string(lang)})
  end
end