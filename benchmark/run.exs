# Helper functions
random_string = fn ->
  x = Enum.random(4..10)
  for _ <- 1..x, into: "", do: <<Enum.random(?a..?z)>>
end

get_trie = fn distance, damerau, items ->
  trie = FuzzyTrie.new(distance, damerau) 

  for _ <- 1..items do
    s = random_string.()

    if s in FuzzyTrie.prefix_fuzzy_search(trie, s) do
      :ok
    else
      FuzzyTrie.insert(trie, s, s)
    end
  end

  trie
end


Benchee.run(
  %{
    "fuzzy_search" => fn trie -> FuzzyTrie.fuzzy_search(trie, random_string.()) end,
    "prefix_fuzzy_search" => fn trie -> FuzzyTrie.prefix_fuzzy_search(trie, random_string.()) end
  },
  inputs: %{
    "1 distance, damerau, 100 items" => get_trie.(1, true, 100),
    "2 distance, damerau, 100 items" => get_trie.(2, true, 100),
    "1 distance, damerau, 1000 items" => get_trie.(1, true, 1000),
    "2 distance, damerau, 1000 items" => get_trie.(2, true, 1000),
    "1 distance, damerau, 10000 items" => get_trie.(1, true, 10000),
    "2 distance, damerau, 10000 items" => get_trie.(2, true, 10000),
    "1 distance, non damerau, 100 items" => get_trie.(1, false, 100),
    "2 distance, non damerau, 100 items" => get_trie.(2, false, 100),
    "1 distance, non damerau, 1000 items" => get_trie.(1, false, 1000),
    "2 distance, non damerau, 1000 items" => get_trie.(2, false, 1000),
    "1 distance, non damerau, 10000 items" => get_trie.(1, false, 10000),
    "2 distance, non damerau, 10000 items" => get_trie.(2, false, 10000)
  }
)
