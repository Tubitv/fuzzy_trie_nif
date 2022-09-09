defmodule FuzzyTrie do
  @moduledoc false

  alias FuzzyTrie.Nif, as: FuzzyTrieNif

  @type fuzzy_trie :: reference()

  @spec new(integer, boolean) :: fuzzy_trie
  def new(distance, damerau) do
    {:ok, trie} = FuzzyTrieNif.new(distance, damerau)
    trie
  end

  @spec insert(fuzzy_trie, String.t(), FuzzyTrieNif.supported_term()) ::
          fuzzy_trie | FuzzyTrieNif.common_errors()
  def insert(fuzzy_trie, key, value) do
    case FuzzyTrieNif.insert(fuzzy_trie, key, value) do
      {:ok, _} -> fuzzy_trie
      other -> other
    end
  end

  @spec len(fuzzy_trie) :: integer
  def len(fuzzy_trie) do
    case FuzzyTrieNif.len(fuzzy_trie) do
      {:ok, len} -> len
      other -> other
    end
  end

  @spec fuzzy_search(fuzzy_trie, String.t()) ::
          {:ok, [FuzzyTrieNif.supported_term()]} | FuzzyTrieNif.common_errors()
  def fuzzy_search(fuzzy_trie, key) do
    case FuzzyTrieNif.fuzzy_search(fuzzy_trie, key) do
      {:ok, values} -> values
      other -> other
    end
  end

  @spec prefix_fuzzy_search(fuzzy_trie, String.t()) ::
          {:ok, [FuzzyTrieNif.supported_term()]} | FuzzyTrieNif.common_errors()
  def prefix_fuzzy_search(fuzzy_trie, key) do
    case FuzzyTrieNif.prefix_fuzzy_search(fuzzy_trie, key) do
      {:ok, values} -> values
      other -> other
    end
  end
end
