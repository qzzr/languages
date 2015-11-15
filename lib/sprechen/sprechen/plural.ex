defmodule Sprechen.Plural do
  cardinals = [{["other"],
                ["aa", "agq", "bas", "byn", "dav", "dje", "dua", "dyo", "ebu", "ewo", "guz",
                 "ia", "kam", "khq", "ki", "kln", "kok", "ksf", "lu", "luo", "luy", "mer",
                 "mfe", "mgh", "mua", "nmg", "nus", "rn", "rw", "sbp", "swc", "tg", "twq",
                 "vai", "wal", "yav", "zgh", "bm", "bo", "dz", "id", "ig", "ii", "ja", "kde",
                 "kea", "km", "ko", "lkt", "lo", "ms", "my", "root", "sah", "ses", "sg", "th",
                 "to", "vi", "yo", "zh"]},
               {["one", "other"],
                ["af", "asa", "az", "bem", "bez", "bg", "brx", "cgg", "chr", "ee", "el", "eo",
                 "es", "eu", "fo", "fur", "gsw", "ha", "haw", "hu", "jgo", "jmc", "ka", "kk",
                 "kkj", "kl", "ks", "ksb", "ky", "lg", "mas", "mgo", "ml", "mn", "nb", "nd",
                 "ne", "nn", "nnh", "no", "nr", "nyn", "om", "or", "os", "ps", "rm", "rof",
                 "rwk", "saq", "seh", "sn", "so", "sq", "ss", "ssy", "st", "ta", "te", "teo",
                 "tig", "tn", "tr", "ts", "ug", "uz", "ve", "vo", "vun", "wae", "xh", "xog",
                 "ak", "ln", "mg", "nso", "pa", "ti", "am", "bn", "fa", "gu", "hi", "kn",
                 "mr", "zu", "as", "ast", "ca", "de", "en", "et", "fi", "fy", "gl", "it",
                 "nl", "sv", "sw", "ur", "da", "ff", "fr", "hy", "kab", "fil", "is", "mk",
                 "pt", "si", "tzm"]},
               {["zero", "one", "other"], ["ksh", "lag", "lv"]},
               {["one", "two", "other"], ["kw", "naq", "se"]},
               {["one", "few", "other"], ["bs", "hr", "sr", "ro", "shi"]},
               {["one", "two", "many", "other"], ["he"]},
               {["one", "two", "few", "other"], ["gd", "sl"]},
               {["one", "few", "many", "other"],
                ["be", "cs", "sk", "lt", "mt", "pl", "ru", "uk"]},
               {["one", "two", "few", "many", "other"], ["br", "ga", "gv"]},
               {["zero", "one", "two", "few", "many", "other"], ["ar", "cy"]}]

  ordinals =  [{["other"],
                ["aa", "agq", "ak", "as", "asa", "ast", "bas", "be", "bem", "bez", "bm", "bo",
                 "br", "brx", "bs", "byn", "cgg", "chr", "dav", "dje", "dua", "dyo", "dz",
                 "ebu", "ee", "eo", "ewo", "ff", "fo", "fur", "ga", "gd", "gsw", "guz", "gv",
                 "ha", "haw", "ia", "ig", "ii", "jgo", "jmc", "kab", "kam", "kde", "kea",
                 "khq", "ki", "kkj", "kl", "kln", "kok", "ks", "ksb", "ksf", "ksh", "kw",
                 "lag", "lg", "lkt", "ln", "lu", "luo", "luy", "mas", "mer", "mfe", "mg",
                 "mgh", "mgo", "mt", "mua", "naq", "nd", "nmg", "nn", "nnh", "nr", "nso",
                 "nus", "nyn", "om", "or", "os", "ps", "rm", "rn", "rof", "rw", "rwk", "sah",
                 "saq", "sbp", "se", "seh", "ses", "sg", "shi", "sn", "so", "ss", "ssy", "st",
                 "swc", "teo", "tg", "ti", "tig", "tn", "to", "ts", "twq", "tzm", "ug", "vai",
                 "ve", "vo", "vun", "wae", "wal", "xh", "xog", "yav", "yo", "zgh", "no", "af",
                 "am", "ar", "bg", "cs", "da", "de", "el", "es", "et", "eu", "fa", "fi", "fy",
                 "gl", "he", "hr", "id", "is", "ja", "km", "kn", "ko", "ky", "lt", "lv", "ml",
                 "mn", "my", "nb", "nl", "pa", "pl", "pt", "root", "ru", "si", "sk", "sl",
                 "sr", "sw", "ta", "te", "th", "tr", "uk", "ur", "uz", "zh", "zu"]},
               {["one", "other"],
                ["fil", "fr", "hy", "lo", "ms", "ro", "vi", "hu", "ne", "sv"]},
               {["many", "other"], ["it", "kk"]},
               {["one", "many", "other"], ["ka", "sq"]},
               {["one", "two", "many", "other"], ["mk"]},
               {["one", "two", "few", "other"], ["ca", "en", "mr"]},
               {["one", "few", "many", "other"], ["az"]},
               {["one", "two", "few", "many", "other"], ["bn", "gu", "hi"]},
               {["zero", "one", "two", "few", "many", "other"], ["cy"]}]

  formats = [cardinal: cardinals, ordinal: ordinals, _: cardinals]

  for {format, groups} <- formats, {expected, languages} <- groups do
    format_kv = case format do
      :_ -> []
      format -> [{"_format", to_string(format)}]
    end

    expected_map = expected
    |> Enum.map(&({&1, {:_, [], nil}}))
    |> Enum.concat(format_kv)

    for language <- languages do
      def missing_plural_keys(unquote(language) <> _, unquote({:%{}, [], expected_map})) do
        []
      end
      def missing_plural_keys(unquote(language) <> _, unquote({:%{}, [], format_kv})) do
        unquote(expected)
      end
    end
  end
end
