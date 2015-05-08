defmodule LanguagesTest do
  use ExUnit.Case

  alias Movement.Languages

  test "return variants" do
    assert "default" in Languages.variants
  end

  test "return languages" do
    assert "en" in Languages.languages
  end

  test "return repos" do
    assert "maker-ui" in Languages.repos
  end

  positives = [
    ["maker-ui", "en"],
    ["maker-ui", "foo"],
    ["maker-ui", ["en"]],
    ["maker-ui", ["foo"]],
    ["maker-ui", ["foo", "en"]],
    ["maker-ui", ["en_US"]],
    ["maker-ui", ["foo", "en_US"]]
  ]

  for positive <- positives do
    for variant <- ["default", "pollcaster"] do
      positive = [variant | positive]
      test "lookup(#{Enum.map(positive, &inspect/1) |> Enum.join(", ")})" do
        assert Languages.lookup(unquote_splicing(positive))
      end
    end
  end
end
