defmodule FuzzyTrie.BuilderTest do
  use ExUnit.Case

  describe "unique value builder" do
    setup do
      {:ok, trie} =
        FuzzyTrie.Builder.new(distance: 1, unique: true)
        |> FuzzyTrie.Builder.insert("something", 0)
        |> FuzzyTrie.Builder.insert("something", 1)
        |> FuzzyTrie.Builder.insert("something else", 2)
        |> FuzzyTrie.Builder.insert("somewhere", 3)
        |> FuzzyTrie.Builder.build()

      [trie: trie]
    end

    test "the length should be 3", %{trie: trie} do
      assert FuzzyTrie.length(trie) == 3
    end

    test "value should be unique", %{trie: trie} do
      assert FuzzyTrie.fuzzy_search(trie, "s0mething") == [1]
      assert FuzzyTrie.prefix_fuzzy_search(trie, "s0me") == [1, 2, 3]
    end
  end

  describe "non-unique value builder" do
    setup do
      {:ok, trie} =
        FuzzyTrie.Builder.new(distance: 1)
        |> FuzzyTrie.Builder.insert("something", 0)
        |> FuzzyTrie.Builder.insert("something", 1)
        |> FuzzyTrie.Builder.insert("something else", 2)
        |> FuzzyTrie.Builder.insert("somewhere", 3)
        |> FuzzyTrie.Builder.build()

      [trie: trie]
    end

    test "the length should be 4", %{trie: trie} do
      assert FuzzyTrie.length(trie) == 4
    end

    test "value should be non unique", %{trie: trie} do
      assert FuzzyTrie.fuzzy_search(trie, "s0mething") == [1, 0]
      assert FuzzyTrie.prefix_fuzzy_search(trie, "s0me") == [3, 2, 1, 0]
    end
  end

  test "should get error when there is unsupported term" do
    res =
      FuzzyTrie.Builder.new()
      |> FuzzyTrie.Builder.insert("something", 0)
      |> FuzzyTrie.Builder.insert("sometime", self())
      |> FuzzyTrie.Builder.insert("somewhere", 1)
      |> FuzzyTrie.Builder.build()

    assert res == {:error, :unsupported_type}
  end
end
