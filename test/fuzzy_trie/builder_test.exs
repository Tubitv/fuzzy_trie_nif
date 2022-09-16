defmodule FuzzyTrie.BuilderTest do
  use ExUnit.Case

  describe "builder with set value_type" do
    setup do
      {:ok, trie} =
        FuzzyTrie.Builder.new!(distance: 1, value_type: :set)
        |> FuzzyTrie.Builder.insert("something", 0)
        |> FuzzyTrie.Builder.insert("something", 1)
        |> FuzzyTrie.Builder.insert("something", 1)
        |> FuzzyTrie.Builder.insert("something else", 2)
        |> FuzzyTrie.Builder.insert("somewhere", 3)
        |> FuzzyTrie.Builder.build()

      [trie: trie]
    end

    test "the length should be 3", %{trie: trie} do
      assert FuzzyTrie.length(trie) == 3
    end

    test "should no more than one value for each key", %{trie: trie} do
      assert FuzzyTrie.fuzzy_search(trie, "s0mething") == [1]
      assert FuzzyTrie.prefix_fuzzy_search(trie, "s0me") == [1, 2, 3]
    end
  end

  describe "builder with bag value_type" do
    setup do
      {:ok, trie} =
        FuzzyTrie.Builder.new!(distance: 1, value_type: :bag)
        |> FuzzyTrie.Builder.insert("something", 0)
        |> FuzzyTrie.Builder.insert("something", 1)
        |> FuzzyTrie.Builder.insert("something", 1)
        |> FuzzyTrie.Builder.insert("something else", 2)
        |> FuzzyTrie.Builder.insert("somewhere", 3)
        |> FuzzyTrie.Builder.build()

      [trie: trie]
    end

    test "the length should be 4", %{trie: trie} do
      assert FuzzyTrie.length(trie) == 4
    end

    test "value should be unique", %{trie: trie} do
      assert FuzzyTrie.fuzzy_search(trie, "s0mething") == [0, 1]
      assert FuzzyTrie.prefix_fuzzy_search(trie, "s0me") == [0, 1, 2, 3]
    end
  end

  describe "builder with duplicate_bag value_type" do
    setup do
      {:ok, trie} =
        FuzzyTrie.Builder.new!(distance: 1, value_type: :duplicate_bag)
        |> FuzzyTrie.Builder.insert("something", 0)
        |> FuzzyTrie.Builder.insert("something", 1)
        |> FuzzyTrie.Builder.insert("something", 1)
        |> FuzzyTrie.Builder.insert("something else", 2)
        |> FuzzyTrie.Builder.insert("somewhere", 3)
        |> FuzzyTrie.Builder.build()

      [trie: trie]
    end

    test "the length should be 4", %{trie: trie} do
      assert FuzzyTrie.length(trie) == 5
    end

    test "should allow duplicate values", %{trie: trie} do
      assert FuzzyTrie.fuzzy_search(trie, "s0mething") == [0, 1, 1]
      assert FuzzyTrie.prefix_fuzzy_search(trie, "s0me") == [0, 1, 1, 2, 3]
    end
  end

  test "should get error when value_type is unsupported" do
    assert {:error, _} = FuzzyTrie.Builder.new(distance: 1, value_type: :unsupported)

    assert_raise ArgumentError, fn ->
      FuzzyTrie.Builder.new!(distance: 1, value_type: :unsupported)
    end
  end

  test "should get error when there is unsupported term" do
    res =
      FuzzyTrie.Builder.new!()
      |> FuzzyTrie.Builder.insert("something", 0)
      |> FuzzyTrie.Builder.insert("sometime", self())
      |> FuzzyTrie.Builder.insert("somewhere", 1)
      |> FuzzyTrie.Builder.build()

    assert res == {:error, :unsupported_type}
  end
end
