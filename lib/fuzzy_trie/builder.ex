defmodule FuzzyTrie.Builder do
  @moduledoc """
  The module for simplifying the process of building fuzzy trie
  The order of values is not guaranteed when using builder

  # Usage
  ```elixir
  options = %FuzzyTrie.Builder{
    damerau: true,
    distance: 2,
    unique: true
  }

  {:ok, trie} =
    FuzzyTrie.Builder.new(distance: 1)
    |> FuzzyTrie.Builder.insert("something", 0)
    |> FuzzyTrie.Builder.insert("something", 1)
    |> FuzzyTrie.Builder.insert("something else", 2)
    |> FuzzyTrie.Builder.insert("somewhere", 3)
    |> FuzzyTrie.Builder.build()
  ```
  """

  use TypedStruct

  alias FuzzyTrie.Types

  @type inner_data :: map() | [{String.t(), Types.supported_term()}]

  typedstruct do
    field :damerau, boolean(), default: false
    field :distance, integer(), default: 1
    field :unique, boolean(), default: false
    field :inner_data, inner_data(), default: []
  end

  @spec new(map() | Keyword.t()) :: __MODULE__.t()
  def new(data \\ %{})

  def new(data) when is_list(data) or is_map(data) do
    case struct(__MODULE__, data) do
      %__MODULE__{unique: true} = builder ->
        Map.put(builder, :inner_data, %{})

      %__MODULE__{} = builder ->
        Map.put(builder, :inner_data, [])
    end
  end

  @spec insert(__MODULE__.t(), String.t(), Types.supported_term()) :: __MODULE__.t()
  def insert(%__MODULE__{inner_data: inner_data} = builder, key, value) do
    %__MODULE__{builder | inner_data: __MODULE__.InnerData.add(inner_data, key, value)}
  end

  @spec build(__MODULE__.t()) :: {:ok, Types.fuzzy_trie()} | {:error, any}
  def build(%__MODULE__{
        damerau: damerau,
        distance: distance,
        inner_data: inner_data
      }) do
    trie = FuzzyTrie.new(distance, damerau)

    inner_data
    |> Stream.map(fn {key, value} -> FuzzyTrie.insert(trie, key, value) end)
    |> Stream.filter(&match?({:error, _}, &1))
    |> Enum.take(1)
    |> case do
      [] -> {:ok, trie}
      [error] -> error
    end
  end
end
