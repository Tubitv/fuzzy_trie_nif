# FuzzyTrieNif
FuzzyTrieNif is a Elixir nif which wrapper the Rust crate [fuzzy_trie](https://crates.io/crates/fuzzy_trie), the nif is built by [Rustler](https://github.com/hansihe/rustler) crate.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `fuzzy_trie_nif` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fuzzy_trie_nif, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/fuzzy_trie_nif>.

## Usage
```elixir
trie =
  FuzzyTrie.new(1, true)
  |> FuzzyTrie.insert("something", 0)
  |> FuzzyTrie.insert("something", 1)
  |> FuzzyTrie.insert("something else", 2)
  |> FuzzyTrie.insert("somewhere", 3)

FuzzyTrie.prefix_fuzzy_search(trie, "s0me") # [0, 1, 2, 3]
FuzzyTrie.fuzzy_search(trie, "s0me") # []
FuzzyTrie.fuzzy_search(trie, "s0mething") # [0, 1]
```
The fuzzy trie can also be built by `FuzzyTrie.Builder`
```elixir
{:ok, trie} =
  FuzzyTrie.Builder.new(distance: 1)
  |> FuzzyTrie.Builder.insert("something", 0)
  |> FuzzyTrie.Builder.insert("something", 1)
  |> FuzzyTrie.Builder.insert("something else", 2)
  |> FuzzyTrie.Builder.insert("somewhere", 3)
  |> FuzzyTrie.Builder.build()
```

## Benchmark
```
Operating System: macOS
CPU Information: Apple M1 Max
Number of Available Cores: 10
Available memory: 64 GB
Elixir 1.13.3
Erlang 24.1.7

##### With input 1 distance, damerau, 100 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search      124.33 K        8.04 μs    ±78.93%           8 μs          12 μs
fuzzy_search             117.58 K        8.50 μs   ±118.26%           8 μs          13 μs

Comparison: 
prefix_fuzzy_search      124.33 K
fuzzy_search             117.58 K - 1.06x slower +0.46 μs

##### With input 1 distance, damerau, 1000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search       89.69 K       11.15 μs    ±77.83%          11 μs          15 μs
fuzzy_search              87.15 K       11.47 μs    ±49.55%          11 μs          16 μs

Comparison: 
prefix_fuzzy_search       89.69 K
fuzzy_search              87.15 K - 1.03x slower +0.32 μs

##### With input 1 distance, damerau, 10000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search       59.62 K       16.77 μs    ±27.25%          16 μs          22 μs
fuzzy_search              58.95 K       16.96 μs    ±19.27%          17 μs          22 μs

Comparison: 
prefix_fuzzy_search       59.62 K
fuzzy_search              58.95 K - 1.01x slower +0.192 μs

##### With input 1 distance, non damerau, 100 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search      122.96 K        8.13 μs   ±291.75%           8 μs          12 μs
fuzzy_search             119.68 K        8.36 μs   ±162.24%           8 μs          13 μs

Comparison: 
prefix_fuzzy_search      122.96 K
fuzzy_search             119.68 K - 1.03x slower +0.22 μs

##### With input 1 distance, non damerau, 1000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search       90.29 K       11.08 μs    ±48.27%          11 μs          15 μs
fuzzy_search              87.98 K       11.37 μs    ±71.51%          11 μs          16 μs

Comparison: 
prefix_fuzzy_search       90.29 K
fuzzy_search              87.98 K - 1.03x slower +0.29 μs

##### With input 1 distance, non damerau, 10000 items #####
Name                          ips        average  deviation         median         99th %
fuzzy_search              58.94 K       16.97 μs    ±29.83%          17 μs          22 μs
prefix_fuzzy_search       58.88 K       16.98 μs   ±103.58%          17 μs          23 μs

Comparison: 
fuzzy_search              58.94 K
prefix_fuzzy_search       58.88 K - 1.00x slower +0.0188 μs

##### With input 2 distance, damerau, 100 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search       49.48 K       20.21 μs    ±37.02%          19 μs          36 μs
fuzzy_search              46.13 K       21.68 μs    ±37.24%          20 μs          38 μs

Comparison: 
prefix_fuzzy_search       49.48 K
fuzzy_search              46.13 K - 1.07x slower +1.47 μs

##### With input 2 distance, damerau, 1000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search       32.97 K       30.33 μs    ±24.40%          29 μs          46 μs
fuzzy_search              31.70 K       31.54 μs    ±25.71%          30 μs          48 μs

Comparison: 
prefix_fuzzy_search       32.97 K
fuzzy_search              31.70 K - 1.04x slower +1.22 μs

##### With input 2 distance, damerau, 10000 items #####
Name                          ips        average  deviation         median         99th %
fuzzy_search              12.54 K       79.75 μs    ±11.49%          78 μs         101 μs
prefix_fuzzy_search       12.18 K       82.10 μs    ±13.28%          80 μs         121 μs

Comparison: 
fuzzy_search              12.54 K
prefix_fuzzy_search       12.18 K - 1.03x slower +2.35 μs

##### With input 2 distance, non damerau, 100 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search       50.28 K       19.89 μs    ±38.79%          19 μs          35 μs
fuzzy_search              46.80 K       21.37 μs    ±45.35%          20 μs          38 μs

Comparison: 
prefix_fuzzy_search       50.28 K
fuzzy_search              46.80 K - 1.07x slower +1.48 μs

##### With input 2 distance, non damerau, 1000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search       33.71 K       29.66 μs    ±26.11%          28 μs          45 μs
fuzzy_search              32.62 K       30.66 μs    ±26.04%          30 μs          47 μs

Comparison: 
prefix_fuzzy_search       33.71 K
fuzzy_search              32.62 K - 1.03x slower +0.99 μs

##### With input 2 distance, non damerau, 10000 items #####
Name                          ips        average  deviation         median         99th %
fuzzy_search              12.94 K       77.28 μs    ±10.61%          76 μs          94 μs
prefix_fuzzy_search       12.24 K       81.71 μs    ±12.96%          80 μs         119 μs

Comparison: 
fuzzy_search              12.94 K
prefix_fuzzy_search       12.24 K - 1.06x slower +4.44 μs
```