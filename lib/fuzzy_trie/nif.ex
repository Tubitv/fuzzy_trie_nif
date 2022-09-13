defmodule FuzzyTrie.Nif do
  @moduledoc false

  use Rustler, otp_app: :fuzzy_trie_nif, crate: "fuzzy_trie_nif"

  alias FuzzyTrie.Types

  @spec new(integer, boolean) :: {:ok, Types.fuzzy_trie()}
  def new(_distance, _damerau), do: error()

  @spec insert(Types.fuzzy_trie(), String.t(), String.t()) :: {:ok, :ok} | Types.common_errors()
  def insert(_fuzzy_trie, _key, _value), do: error()

  @spec len(Types.fuzzy_trie()) :: {:ok, integer} | Types.common_errors()
  def len(_fuzzy_trie), do: error()

  @spec fuzzy_search(Types.fuzzy_trie(), String.t()) ::
          {:ok, [String.t()]} | Types.common_errors()
  def fuzzy_search(_fuzzy_trie, _key), do: error()

  @spec prefix_fuzzy_search(Types.fuzzy_trie(), String.t()) ::
          {:ok, [String.t()]} | Types.common_errors()
  def prefix_fuzzy_search(_fuzzy_trie, _key), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
