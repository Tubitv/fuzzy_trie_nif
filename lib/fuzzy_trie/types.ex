defmodule FuzzyTrie.Types do
  @moduledoc """
  Provides some common types
  """

  @type fuzzy_trie :: reference()
  @type supported_term :: integer() | atom() | tuple() | list() | String.t()
  @type common_errors :: {:error, :lock_fail} | {:error, :unsupported_type}
end
