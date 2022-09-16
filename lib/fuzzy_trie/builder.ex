defmodule FuzzyTrie.Builder do
  @moduledoc """
  The module for simplifying the process of building fuzzy trie

  * value_type
    - :set
    When insert a key to the fuzzy trie, the old object with same key will be replaced,
    The queries returns either the empty list or a list with one element,
    - :bag
    The quries returns a list of arbitrary length, the elements in the list are unique
    - :duplicate_bag
    The quries returns a list of arbitrary length, the elements in the list are not unique

  # Usage
  ```elixir
  options = %FuzzyTrie.Builder{
    damerau: true,
    distance: 2,
    value_type: :set
  }

  {:ok, trie} =
    FuzzyTrie.Builder.new!(distance: 1)
    |> FuzzyTrie.Builder.insert("something", 0)
    |> FuzzyTrie.Builder.insert("something", 1)
    |> FuzzyTrie.Builder.insert("something else", 2)
    |> FuzzyTrie.Builder.insert("somewhere", 3)
    |> FuzzyTrie.Builder.build()
  ```
  """

  use TypedStruct
  use Domo

  alias FuzzyTrie.Types

  @type value_type :: atom
  precond value_type: &(&1 in [:set, :bag, :duplicate_bag])

  @type inner_data_value :: term()

  @type inner_data :: %{optional(String.t()) => inner_data_value}

  typedstruct do
    field :damerau, boolean(), default: false
    field :distance, integer(), default: 1
    field :value_type, value_type(), default: :set
    field :inner_data, inner_data(), default: %{}
  end

  @spec insert(__MODULE__.t(), String.t(), Types.supported_term()) :: __MODULE__.t()
  def insert(%__MODULE__{inner_data: %{} = inner_data, value_type: :set} = builder, key, value) do
    inner_data = Map.put(inner_data, key, value)
    %__MODULE__{builder | inner_data: inner_data}
  end

  def insert(%__MODULE__{inner_data: %{} = inner_data, value_type: :bag} = builder, key, value) do
    inner_data = Map.update(inner_data, key, MapSet.new([value]), &MapSet.put(&1, value))
    %__MODULE__{builder | inner_data: inner_data}
  end

  def insert(
        %__MODULE__{
          inner_data: %{} = inner_data,
          value_type: :duplicate_bag
        } = builder,
        key,
        value
      ) do
    inner_data = Map.update(inner_data, key, [value], &[value | &1])
    %__MODULE__{builder | inner_data: inner_data}
  end

  @spec build(__MODULE__.t()) :: {:ok, Types.fuzzy_trie()} | {:error, any}
  def build(%__MODULE__{
        damerau: damerau,
        distance: distance,
        inner_data: inner_data,
        value_type: value_type
      }) do
    trie = FuzzyTrie.new(distance, damerau)

    inner_data
    |> Stream.flat_map(fn {key, value} ->
      for value <- iter_value(value_type, value) do
        FuzzyTrie.insert(trie, key, value)
      end
    end)
    |> Stream.filter(&match?({:error, _}, &1))
    |> Enum.take(1)
    |> case do
      [] -> {:ok, trie}
      [error] -> error
    end
  end

  defp iter_value(:set, value), do: [value]
  defp iter_value(:bag, value), do: MapSet.to_list(value)
  defp iter_value(:duplicate_bag, value), do: Enum.reverse(value)
end
