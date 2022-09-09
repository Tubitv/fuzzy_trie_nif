defmodule FuzzyTrie.Nif do
  @moduledoc false

  use Rustler, otp_app: :fuzzy_trie_nif, crate: "fuzzy_trie_nif"

  @type fuzzy_trie :: reference()
  @type supported_term :: integer() | atom() | tuple() | list() | String.t()
  @type common_errors :: {:error, :lock_fail} | {:error, :unsupported_type}

  @spec new(integer, boolean) :: {:ok, fuzzy_trie}
  def new(_distance, _damerau), do: error()

  @spec insert(fuzzy_trie, String.t(), String.t()) :: {:ok, :ok} | common_errors
  def insert(_fuzzy_trie, _key, _value), do: error()

  @spec len(fuzzy_trie) :: {:ok, integer} | common_errors
  def len(_fuzzy_trie), do: error()

  @spec fuzzy_search(fuzzy_trie, String.t()) :: {:ok, [String.t()]} | common_errors
  def fuzzy_search(_fuzzy_trie, _key), do: error()

  @spec prefix_fuzzy_search(fuzzy_trie, String.t()) :: {:ok, [String.t()]} | common_errors
  def prefix_fuzzy_search(_fuzzy_trie, _key), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
