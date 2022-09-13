defmodule FuzzyTrie do
  @moduledoc false

  alias FuzzyTrie.Types

  @spec new(integer, boolean) :: Types.fuzzy_trie()
  def new(distance, damerau) do
    {:ok, trie} = FuzzyTrie.Nif.new(distance, damerau)
    trie
  end

  @spec insert(Types.fuzzy_trie(), String.t(), Types.supported_term()) ::
          Types.fuzzy_trie() | Types.common_errors()
  def insert(fuzzy_trie, key, value) do
    case FuzzyTrie.Nif.insert(fuzzy_trie, key, value) do
      {:ok, _} -> fuzzy_trie
      other -> other
    end
  end

  @spec length(Types.fuzzy_trie()) :: integer
  def length(fuzzy_trie) do
    case FuzzyTrie.Nif.len(fuzzy_trie) do
      {:ok, len} -> len
      other -> other
    end
  end

  @spec fuzzy_search(Types.fuzzy_trie(), String.t()) ::
          {:ok, [Types.supported_term()]} | Types.common_errors()
  def fuzzy_search(fuzzy_trie, key) do
    case FuzzyTrie.Nif.fuzzy_search(fuzzy_trie, key) do
      {:ok, values} -> values
      other -> other
    end
  end

  @spec prefix_fuzzy_search(Types.fuzzy_trie(), String.t()) ::
          {:ok, [Types.supported_term()]} | Types.common_errors()
  def prefix_fuzzy_search(fuzzy_trie, key) do
    case FuzzyTrie.Nif.prefix_fuzzy_search(fuzzy_trie, key) do
      {:ok, values} -> values
      other -> other
    end
  end
end
