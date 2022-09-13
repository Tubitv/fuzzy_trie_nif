defprotocol FuzzyTrie.Builder.InnerData do
  @doc "Add data in FuzzyTrie builder"
  def add(inner_data, key, value)
end

defimpl FuzzyTrie.Builder.InnerData, for: List do
  def add(inner_data, key, value) do
    [{key, value} | inner_data]
  end
end

defimpl FuzzyTrie.Builder.InnerData, for: Map do
  def add(inner_data, key, value) do
    Map.put(inner_data, key, value)
  end
end
